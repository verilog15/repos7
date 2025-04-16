﻿#if __IOS__ || MACCATALYST
using PlatformView = Microsoft.Maui.Platform.MauiTextField;
#elif MONOANDROID
using PlatformView = AndroidX.AppCompat.Widget.AppCompatEditText;
#elif WINDOWS
using PlatformView = Microsoft.UI.Xaml.Controls.TextBox;
#elif TIZEN
using PlatformView = Tizen.UIExtensions.NUI.Entry;
#elif (NETSTANDARD || !PLATFORM) || (NET6_0_OR_GREATER && !IOS && !ANDROID && !TIZEN)
using PlatformView = System.Object;
#endif

namespace Microsoft.Maui.Handlers
{
	public partial interface IEntryHandler : IViewHandler
	{
		new IEntry VirtualView { get; }
		new PlatformView PlatformView { get; }
	}
}