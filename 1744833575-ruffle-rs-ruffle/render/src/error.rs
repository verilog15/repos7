use std::borrow::Cow;

use thiserror::Error;

use crate::bitmap::BitmapHandle;

#[derive(Error, Debug)]
pub enum Error {
    #[error("Bitmap texture is larger than the rendering device supports")]
    TooLarge,

    #[error("Bitmap texture has a size of 0 and is invalid")]
    InvalidSize,

    #[error("Unknown bitmap format")]
    UnknownType,

    #[error("Invalid ZLIB compression")]
    InvalidZlibCompression,

    #[error("Invalid JPEG")]
    InvalidJpeg(#[from] jpeg_decoder::Error),

    #[error("Invalid PNG")]
    InvalidPng(#[from] png::DecodingError),

    #[error("Invalid GIF")]
    InvalidGif(#[from] gif::DecodingError),

    #[error("Empty GIF")]
    EmptyGif,

    #[error("Unsupported DefineBitsLossless{0} format {1:?}")]
    UnsupportedLosslessFormat(u8, swf::BitmapFormat),

    #[cfg(feature = "web")]
    #[error("Javascript error")]
    JavascriptError(wasm_bindgen::JsValue),

    #[error("Unknown handle {0:?}")]
    UnknownHandle(BitmapHandle),

    #[error("Not yet implemented: {0}")]
    Unimplemented(Cow<'static, str>),
}
