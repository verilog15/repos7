/**
 * The copyright in this software is being made available under the BSD License,
 * included below. This software may be subject to other third party and contributor
 * rights, including patent rights, and no such rights are granted under this license.
 *
 * Copyright (c) 2013, Dash Industry Forum.
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without modification,
 * are permitted provided that the following conditions are met:
 *  * Redistributions of source code must retain the above copyright notice, this
 *  list of conditions and the following disclaimer.
 *  * Redistributions in binary form must reproduce the above copyright notice,
 *  this list of conditions and the following disclaimer in the documentation and/or
 *  other materials provided with the distribution.
 *  * Neither the name of Dash Industry Forum nor the names of its
 *  contributors may be used to endorse or promote products derived from this software
 *  without specific prior written permission.
 *
 *  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS AS IS AND ANY
 *  EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 *  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
 *  IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
 *  INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
 *  NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 *  PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
 *  WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 *  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 *  POSSIBILITY OF SUCH DAMAGE.
 */

/**
 * Initial implementation of EME
 *
 * Implemented by Google Chrome prior to v36
 *
 * @implements ProtectionModel
 * @class
 */
import ProtectionKeyController from '../controllers/ProtectionKeyController.js';
import NeedKey from '../vo/NeedKey.js';
import DashJSError from '../../vo/DashJSError.js';
import KeyMessage from '../vo/KeyMessage.js';
import KeySystemConfiguration from '../vo/KeySystemConfiguration.js';
import KeySystemAccess from '../vo/KeySystemAccess.js';
import ProtectionErrors from '../errors/ProtectionErrors.js';
import FactoryMaker from '../../../core/FactoryMaker.js';
import ProtectionConstants from '../../constants/ProtectionConstants.js';

function ProtectionModel_01b(config) {

    config = config || {};
    const context = this.context;
    const eventBus = config.eventBus;//Need to pass in here so we can use same instance since this is optional module
    const events = config.events;
    const debug = config.debug;
    const api = config.api;
    const errHandler = config.errHandler;

    let instance,
        logger,
        videoElement,
        keySystem,
        protectionKeyController,

        // With this version of the EME APIs, sessionIds are not assigned to
        // sessions until the first key message is received.  We are assuming
        // that in the case of multiple sessions, key messages will be received
        // in the order that generateKeyRequest() is called.
        // Holding spot for newly-created sessions until we determine whether or
        // not the CDM supports sessionIds
        pendingSessions,

        // List of sessions that have been initialized.  Only the first position will
        // be used in the case that the CDM does not support sessionIds
        sessionTokens,

        // Not all CDMs support the notion of sessionIds.  Without sessionIds
        // there is no way for us to differentiate between sessions, therefore
        // we must only allow a single session.  Once we receive the first key
        // message we can set this flag to determine if more sessions are allowed
        moreSessionsAllowed,

        // This is our main event handler for all desired HTMLMediaElement events
        // related to EME.  These events are translated into our API-independent
        // versions of the same events
        eventHandler;

    function setup() {
        logger = debug.getLogger(instance);
        videoElement = null;
        keySystem = null;
        pendingSessions = [];
        sessionTokens = [];
        protectionKeyController = ProtectionKeyController(context).getInstance();
        eventHandler = createEventHandler();
    }

    function reset() {
        if (videoElement) {
            removeEventListeners();
        }
        for (let i = 0; i < sessionTokens.length; i++) {
            closeKeySession(sessionTokens[i]);
        }
        eventBus.trigger(events.TEARDOWN_COMPLETE);
    }

    function getAllInitData() {
        const retVal = [];
        for (let i = 0; i < pendingSessions.length; i++) {
            retVal.push(pendingSessions[i].initData);
        }
        for (let i = 0; i < sessionTokens.length; i++) {
            retVal.push(sessionTokens[i].initData);
        }
        return retVal;
    }

    function getSessionTokens() {
        return sessionTokens.concat(pendingSessions);
    }

    function requestKeySystemAccess(ksConfigurations) {
        return new Promise((resolve, reject) => {
            let ve = videoElement;
            if (!ve) { // Must have a video element to do this capability tests
                ve = document.createElement('video');
            }

            // Try key systems in order, first one with supported key system configuration
            // is used
            let found = false;
            for (let ksIdx = 0; ksIdx < ksConfigurations.length; ksIdx++) {
                const systemString = ksConfigurations[ksIdx].ks.systemString;
                const configs = ksConfigurations[ksIdx].configs;
                let supportedAudio = null;
                let supportedVideo = null;

                // Try key system configs in order, first one with supported audio/video
                // is used
                for (let configIdx = 0; configIdx < configs.length; configIdx++) {
                    //let audios = configs[configIdx].audioCapabilities;
                    const videos = configs[configIdx].videoCapabilities;
                    // Look for supported video container/codecs
                    if (videos && videos.length !== 0) {
                        supportedVideo = []; // Indicates that we have a requested video config
                        for (let videoIdx = 0; videoIdx < videos.length; videoIdx++) {
                            if (ve.canPlayType(videos[videoIdx].contentType, systemString) !== '') {
                                supportedVideo.push(videos[videoIdx]);
                            }
                        }
                    }

                    // No supported audio or video in this configuration OR we have
                    // requested audio or video configuration that is not supported
                    if ((!supportedAudio && !supportedVideo) ||
                        (supportedAudio && supportedAudio.length === 0) ||
                        (supportedVideo && supportedVideo.length === 0)) {
                        continue;
                    }

                    // This configuration is supported
                    found = true;
                    const ksConfig = new KeySystemConfiguration(supportedAudio, supportedVideo);
                    const ks = protectionKeyController.getKeySystemBySystemString(systemString);
                    const keySystemAccess = new KeySystemAccess(ks, ksConfig)
                    eventBus.trigger(events.KEY_SYSTEM_ACCESS_COMPLETE, { data: keySystemAccess });
                    resolve({ data: keySystemAccess });
                    break;
                }
            }
            if (!found) {
                const errorMessage = 'Key system access denied! -- No valid audio/video content configurations detected!';
                eventBus.trigger(events.KEY_SYSTEM_ACCESS_COMPLETE, { error: errorMessage });
                reject({ error: errorMessage });
            }
        })

    }

    function selectKeySystem(keySystemAccess) {
        keySystem = keySystemAccess.keySystem;
        return Promise.resolve(keySystem);
    }

    function setMediaElement(mediaElement) {
        if (videoElement === mediaElement) {
            return;
        }

        // Replacing the previous element
        if (videoElement) {
            removeEventListeners();

            // Close any open sessions - avoids memory leak on LG webOS 2016/2017 TVs
            for (var i = 0; i < sessionTokens.length; i++) {
                closeKeySession(sessionTokens[i]);
            }
            sessionTokens = [];
        }

        videoElement = mediaElement;

        // Only if we are not detaching from the existing element
        if (videoElement) {
            videoElement.addEventListener(api.keyerror, eventHandler);
            videoElement.addEventListener(api.needkey, eventHandler);
            videoElement.addEventListener(api.keymessage, eventHandler);
            videoElement.addEventListener(api.keyadded, eventHandler);
            eventBus.trigger(events.VIDEO_ELEMENT_SELECTED);
        }
    }

    function createKeySession(ksInfo) {
        if (!keySystem) {
            throw new Error('Can not create sessions until you have selected a key system');
        }

        // Determine if creating a new session is allowed
        if (moreSessionsAllowed || sessionTokens.length === 0) {
            const newSession = { // Implements SessionToken
                sessionId: null,
                keyId: ksInfo.keyId,
                normalizedKeyId: ksInfo && ksInfo.keyId && typeof ksInfo.keyId === 'string' ? ksInfo.keyId.replace(/-/g, '').toLowerCase() : '',
                initData: ksInfo.initData,
                hasTriggeredKeyStatusMapUpdate: false,

                getKeyId: function () {
                    return this.keyId;
                },

                getSessionId: function () {
                    return this.sessionId;
                },

                getExpirationTime: function () {
                    return NaN;
                },

                getSessionType: function () {
                    return 'temporary';
                },

                getKeyStatuses: function () {
                    return {
                        size: 0,
                        has: () => {
                            return false
                        },
                        get: () => {
                            return undefined
                        }
                    }
                }
            };
            pendingSessions.push(newSession);

            // Send our request to the CDM
            videoElement[api.generateKeyRequest](keySystem.systemString, new Uint8Array(ksInfo.initData));

            return newSession;

        } else {
            throw new Error('Multiple sessions not allowed!');
        }

    }

    function updateKeySession(sessionToken, message) {
        const sessionId = sessionToken.sessionId;
        if (!protectionKeyController.isClearKey(keySystem)) {
            // Send our request to the CDM
            videoElement[api.addKey](keySystem.systemString,
                new Uint8Array(message), new Uint8Array(sessionToken.initData), sessionId);
        } else {
            // For clearkey, message is a ClearKeyKeySet
            for (let i = 0; i < message.keyPairs.length; i++) {
                videoElement[api.addKey](keySystem.systemString,
                    message.keyPairs[i].key, message.keyPairs[i].keyID, sessionId);
            }
        }
        eventBus.trigger(events.KEY_SESSION_UPDATED);
    }

    function closeKeySession(sessionToken) {
        // Send our request to the CDM
        try {
            videoElement[api.cancelKeyRequest](keySystem.systemString, sessionToken.sessionId);
        } catch (error) {
            eventBus.trigger(events.KEY_SESSION_CLOSED, {
                data: null,
                error: 'Error closing session (' + sessionToken.sessionId + ') ' + error.message
            });
        }
    }

    function setServerCertificate(/*serverCertificate*/) { /* Not supported */
    }

    function loadKeySession(/*ksInfo*/) { /* Not supported */
    }

    function removeKeySession(/*sessionToken*/) { /* Not supported */
    }

    function createEventHandler() {
        return {
            handleEvent: function (event) {
                let sessionToken = null;
                switch (event.type) {
                    case api.needkey:
                        let initData = ArrayBuffer.isView(event.initData) ? event.initData.buffer : event.initData;
                        eventBus.trigger(events.NEED_KEY, { key: new NeedKey(initData, ProtectionConstants.INITIALIZATION_DATA_TYPE_CENC) });
                        break;

                    case api.keyerror:
                        sessionToken = findSessionByID(sessionTokens, event.sessionId);
                        if (!sessionToken) {
                            sessionToken = findSessionByID(pendingSessions, event.sessionId);
                        }

                        if (sessionToken) {
                            let code = ProtectionErrors.MEDIA_KEYERR_CODE;
                            let msg = '';
                            switch (event.errorCode.code) {
                                case 1:
                                    code = ProtectionErrors.MEDIA_KEYERR_UNKNOWN_CODE;
                                    msg += 'MEDIA_KEYERR_UNKNOWN - ' + ProtectionErrors.MEDIA_KEYERR_UNKNOWN_MESSAGE;
                                    break;
                                case 2:
                                    code = ProtectionErrors.MEDIA_KEYERR_CLIENT_CODE;
                                    msg += 'MEDIA_KEYERR_CLIENT - ' + ProtectionErrors.MEDIA_KEYERR_CLIENT_MESSAGE;
                                    break;
                                case 3:
                                    code = ProtectionErrors.MEDIA_KEYERR_SERVICE_CODE;
                                    msg += 'MEDIA_KEYERR_SERVICE - ' + ProtectionErrors.MEDIA_KEYERR_SERVICE_MESSAGE;
                                    break;
                                case 4:
                                    code = ProtectionErrors.MEDIA_KEYERR_OUTPUT_CODE;
                                    msg += 'MEDIA_KEYERR_OUTPUT - ' + ProtectionErrors.MEDIA_KEYERR_OUTPUT_MESSAGE;
                                    break;
                                case 5:
                                    code = ProtectionErrors.MEDIA_KEYERR_HARDWARECHANGE_CODE;
                                    msg += 'MEDIA_KEYERR_HARDWARECHANGE - ' + ProtectionErrors.MEDIA_KEYERR_HARDWARECHANGE_MESSAGE;
                                    break;
                                case 6:
                                    code = ProtectionErrors.MEDIA_KEYERR_DOMAIN_CODE;
                                    msg += 'MEDIA_KEYERR_DOMAIN - ' + ProtectionErrors.MEDIA_KEYERR_DOMAIN_MESSAGE;
                                    break;
                            }
                            msg += '  System Code = ' + event.systemCode;
                            // TODO: Build error string based on key error
                            eventBus.trigger(events.KEY_ERROR, { error: new DashJSError(code, msg, sessionToken) });
                        } else {
                            logger.error('No session token found for key error');
                        }
                        break;

                    case api.keyadded:
                        sessionToken = findSessionByID(sessionTokens, event.sessionId);
                        if (!sessionToken) {
                            sessionToken = findSessionByID(pendingSessions, event.sessionId);
                        }

                        if (sessionToken) {
                            logger.debug('DRM: Key added.');
                            eventBus.trigger(events.KEY_ADDED, { data: sessionToken });//TODO not sure anything is using sessionToken? why there?
                        } else {
                            logger.debug('No session token found for key added');
                        }
                        break;

                    case api.keymessage:
                        // If this CDM does not support session IDs, we will be limited
                        // to a single session
                        moreSessionsAllowed = (event.sessionId !== null) && (event.sessionId !== undefined);

                        // SessionIDs supported
                        if (moreSessionsAllowed) {
                            // Attempt to find an uninitialized token with this sessionId
                            sessionToken = findSessionByID(sessionTokens, event.sessionId);
                            if (!sessionToken && pendingSessions.length > 0) {

                                // This is the first message for our latest session, so set the
                                // sessionId and add it to our list
                                sessionToken = pendingSessions.shift();
                                sessionTokens.push(sessionToken);
                                sessionToken.sessionId = event.sessionId;

                                eventBus.trigger(events.KEY_SESSION_CREATED, { data: sessionToken });
                            }
                        } else if (pendingSessions.length > 0) { // SessionIDs not supported
                            sessionToken = pendingSessions.shift();
                            sessionTokens.push(sessionToken);

                            if (pendingSessions.length !== 0) {
                                errHandler.error(new DashJSError(ProtectionErrors.MEDIA_KEY_MESSAGE_ERROR_CODE, ProtectionErrors.MEDIA_KEY_MESSAGE_ERROR_MESSAGE));
                            }
                        }

                        if (sessionToken) {
                            let message = ArrayBuffer.isView(event.message) ? event.message.buffer : event.message;

                            // For ClearKey, the spec mandates that you pass this message to the
                            // addKey method, so we always save it to the token since there is no
                            // way to tell which key system is in use
                            sessionToken.keyMessage = message;
                            eventBus.trigger(events.INTERNAL_KEY_MESSAGE, { data: new KeyMessage(sessionToken, message, event.defaultURL) });

                        } else {
                            logger.warn('No session token found for key message');
                        }
                        break;
                }
            }
        };
    }


    /**
     * Helper function to retrieve the stored session token based on a given
     * sessionId value
     *
     * @param {Array} sessionArray - the array of sessions to search
     * @param {*} sessionId - the sessionId to search for
     * @returns {*} the session token with the given sessionId
     */
    function findSessionByID(sessionArray, sessionId) {
        if (!sessionId || !sessionArray) {
            return null;
        } else {
            const len = sessionArray.length;
            for (let i = 0; i < len; i++) {
                if (sessionArray[i].sessionId == sessionId) {
                    return sessionArray[i];
                }
            }
            return null;
        }
    }

    function removeEventListeners() {
        videoElement.removeEventListener(api.keyerror, eventHandler);
        videoElement.removeEventListener(api.needkey, eventHandler);
        videoElement.removeEventListener(api.keymessage, eventHandler);
        videoElement.removeEventListener(api.keyadded, eventHandler);
    }

    instance = {
        getAllInitData,
        getSessionTokens,
        requestKeySystemAccess,
        selectKeySystem,
        setMediaElement,
        createKeySession,
        updateKeySession,
        closeKeySession,
        setServerCertificate,
        loadKeySession,
        removeKeySession,
        stop: reset,
        reset
    };

    setup();

    return instance;
}

ProtectionModel_01b.__dashjs_factory_name = 'ProtectionModel_01b';
export default FactoryMaker.getClassFactory(ProtectionModel_01b);
