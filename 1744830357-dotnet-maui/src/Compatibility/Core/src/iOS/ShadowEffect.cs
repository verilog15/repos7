using System;
using System.ComponentModel;
using Microsoft.Maui.Controls.Internals;
using Microsoft.Maui.Controls.Platform;
using Microsoft.Maui.Graphics;
using ObjCRuntime;
using UIKit;
using PlatformElement = Microsoft.Maui.Controls.PlatformConfiguration.iOSSpecific.VisualElement;

namespace Microsoft.Maui.Controls.Compatibility.Platform.iOS
{
	[Preserve(AllMembers = true)]
	internal class ShadowEffect : PlatformEffect
	{
		UIView ShadowView => Control ?? Container;

		protected override void OnAttached() => UpdateShadow();

		protected override void OnDetached()
		{
			var layer = ShadowView.Layer;

			if (layer != null)
			{
				layer.ShadowColor = Colors.Transparent.ToCGColor();
				layer.ShadowOpacity = 0;
			}
		}

		protected override void OnElementPropertyChanged(PropertyChangedEventArgs args)
		{
			if (args.PropertyName == PlatformElement.IsShadowEnabledProperty.PropertyName ||
				args.PropertyName == PlatformElement.ShadowColorProperty.PropertyName ||
				args.PropertyName == PlatformElement.ShadowOffsetProperty.PropertyName ||
				args.PropertyName == PlatformElement.ShadowRadiusProperty.PropertyName ||
				args.PropertyName == PlatformElement.ShadowOpacityProperty.PropertyName)
			{
				UpdateShadow();
			}
		}

		private void UpdateShadow()
		{
			var layer = ShadowView.Layer;

			layer.ShadowColor = PlatformElement.GetShadowColor(Element).ToCGColor();
			layer.ShadowOffset = PlatformElement.GetShadowOffset(Element).ToSizeF();
			layer.ShadowRadius = (nfloat)PlatformElement.GetShadowRadius(Element);
			layer.ShadowOpacity = (float)PlatformElement.GetShadowOpacity(Element);
		}
	}
}
