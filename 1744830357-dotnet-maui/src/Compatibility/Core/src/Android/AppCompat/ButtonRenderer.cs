using System;
using System.ComponentModel;
using Android.Content;
using Android.Graphics;
using Android.Util;
using Android.Views;
using AndroidX.AppCompat.Widget;
using Microsoft.Maui.Controls.Internals;
using Microsoft.Maui.Controls.Platform;
using Microsoft.Maui.Controls.PlatformConfiguration.AndroidSpecific;
using AColor = Android.Graphics.Color;
using AView = Android.Views.View;

namespace Microsoft.Maui.Controls.Compatibility.Platform.Android.AppCompat
{
	[System.Obsolete(Compatibility.Hosting.MauiAppBuilderExtensions.UseMapperInstead)]
	public class ButtonRenderer : ViewRenderer<Button, AppCompatButton>,
		AView.IOnAttachStateChangeListener, AView.IOnClickListener, AView.IOnTouchListener,
		IBorderVisualElementRenderer, IButtonLayoutRenderer, IDisposedState
	{
		BorderBackgroundManager _backgroundTracker;
		TextColorSwitcher _textColorSwitcher;
		float _defaultFontSize;
		Typeface _defaultTypeface;
		bool _isDisposed;
		ButtonLayoutManager _buttonLayoutManager;

		public ButtonRenderer(Context context) : base(context)
		{
			AutoPackage = false;
			_backgroundTracker = new BorderBackgroundManager(this);
			_buttonLayoutManager = new ButtonLayoutManager(this);
		}

		global::Android.Widget.Button NativeButton => Control;

		protected override void SetContentDescription()
			=> base.SetContentDescription(false);

		public override SizeRequest GetDesiredSize(int widthConstraint, int heightConstraint)
		{
			return _buttonLayoutManager.GetDesiredSize(widthConstraint, heightConstraint);
		}

		void AView.IOnAttachStateChangeListener.OnViewAttachedToWindow(AView attachedView) =>
			_buttonLayoutManager?.OnViewAttachedToWindow(attachedView);

		void AView.IOnAttachStateChangeListener.OnViewDetachedFromWindow(AView detachedView) =>
			_buttonLayoutManager?.OnViewDetachedFromWindow(detachedView);

		protected override void OnLayout(bool changed, int l, int t, int r, int b)
		{
			_buttonLayoutManager?.OnLayout(changed, l, t, r, b);
			base.OnLayout(changed, l, t, r, b);
		}

		protected override AppCompatButton CreateNativeControl()
		{
			return new AppCompatButton(Context);
		}

		protected override void Dispose(bool disposing)
		{
			if (_isDisposed)
				return;

			_isDisposed = true;

			if (disposing)
			{
				if (Control != null)
				{
					Control.SetOnClickListener(null);
					Control.SetOnTouchListener(null);
					Control.RemoveOnAttachStateChangeListener(this);
					_textColorSwitcher = null;
				}
				_backgroundTracker?.Dispose();
				_backgroundTracker = null;
				_buttonLayoutManager?.Dispose();
				_buttonLayoutManager = null;
			}

			base.Dispose(disposing);
		}

		protected override void OnElementChanged(ElementChangedEventArgs<Button> e)
		{
			base.OnElementChanged(e);

			if (e.NewElement != null)
			{
				if (Control == null)
				{
					AppCompatButton button = CreateNativeControl();

					button.SetOnClickListener(this);
					button.SetOnTouchListener(this);
					button.AddOnAttachStateChangeListener(this);
					_textColorSwitcher = new TextColorSwitcher(button.TextColors, e.NewElement.UseLegacyColorManagement());

					SetNativeControl(button);
				}

				_defaultFontSize = 0f;

				_buttonLayoutManager?.Update();
				UpdateAll();
			}
		}

		protected override void OnElementPropertyChanged(object sender, PropertyChangedEventArgs e)
		{
			if (this.IsDisposed())
			{
				return;
			}

			if (e.PropertyName == Button.TextColorProperty.PropertyName)
				UpdateTextColor();
			else if (e.PropertyName == VisualElement.IsEnabledProperty.PropertyName)
				UpdateEnabled();
			else if (e.PropertyName == FontElement.FontAttributesProperty.PropertyName
					 || e.PropertyName == FontElement.FontAutoScalingEnabledProperty.PropertyName
					 || e.PropertyName == FontElement.FontFamilyProperty.PropertyName
					 || e.PropertyName == FontElement.FontSizeProperty.PropertyName)
				UpdateFont();
			else if (e.PropertyName == Button.CharacterSpacingProperty.PropertyName)
				UpdateCharacterSpacing();

			base.OnElementPropertyChanged(sender, e);
		}

		[PortHandler]
		protected override void UpdateBackgroundColor()
		{
			if (Element == null || Control == null)
				return;

			_backgroundTracker?.UpdateDrawable();
		}

		void UpdateAll()
		{
			UpdateFont();
			UpdateTextColor();
			UpdateEnabled();
			UpdateBackgroundColor();
			UpdateCharacterSpacing();
		}

		[PortHandler]
		void UpdateEnabled()
		{
			Control.Enabled = Element.IsEnabled;
		}

		[PortHandler]
		void UpdateFont()
		{
			Button button = Element;
			Font font = (button as ITextStyle).Font;

			if (font == Font.Default && _defaultFontSize == 0f)
				return;

			if (_defaultFontSize == 0f)
			{
				_defaultTypeface = NativeButton.Typeface;
				_defaultFontSize = NativeButton.TextSize;
			}

			if (font == Font.Default)
			{
				NativeButton.Typeface = _defaultTypeface;
				NativeButton.SetTextSize(ComplexUnitType.Px, _defaultFontSize);
			}
			else
			{
				NativeButton.Typeface = font.ToTypeface(Element.RequireFontManager());
				NativeButton.SetTextSize(ComplexUnitType.Sp, (float)font.Size);
			}
		}

		[PortHandler]
		void UpdateTextColor()
		{
			_textColorSwitcher?.UpdateTextColor(Control, Element.TextColor);
		}

		[PortHandler]
		void UpdateCharacterSpacing()
		{
			NativeButton.LetterSpacing = Element.CharacterSpacing.ToEm();
		}

		void IOnClickListener.OnClick(AView v) => ButtonElementManager.OnClick(Element, Element, v);

		bool IOnTouchListener.OnTouch(AView v, MotionEvent e) => ButtonElementManager.OnTouch(Element, Element, v, e);

		float IBorderVisualElementRenderer.ShadowRadius => Control.ShadowRadius;
		float IBorderVisualElementRenderer.ShadowDx => Control.ShadowDx;
		float IBorderVisualElementRenderer.ShadowDy => Control.ShadowDy;
		AColor IBorderVisualElementRenderer.ShadowColor => Control.ShadowColor;
		bool IBorderVisualElementRenderer.UseDefaultPadding() => Element.OnThisPlatform().UseDefaultPadding();
		bool IBorderVisualElementRenderer.UseDefaultShadow() => Element.OnThisPlatform().UseDefaultShadow();
		bool IBorderVisualElementRenderer.IsShadowEnabled() => true;
		VisualElement IBorderVisualElementRenderer.Element => Element;
		AView IBorderVisualElementRenderer.View => Control;
		event EventHandler<VisualElementChangedEventArgs> IBorderVisualElementRenderer.ElementChanged
		{
			add => ((IVisualElementRenderer)this).ElementChanged += value;
			remove => ((IVisualElementRenderer)this).ElementChanged -= value;
		}

		event EventHandler<VisualElementChangedEventArgs> IButtonLayoutRenderer.ElementChanged
		{
			add => ((IVisualElementRenderer)this).ElementChanged += value;
			remove => ((IVisualElementRenderer)this).ElementChanged -= value;
		}

		AppCompatButton IButtonLayoutRenderer.View => Control;
		bool IDisposedState.IsDisposed => _isDisposed || !Control.IsAlive();
	}
}
