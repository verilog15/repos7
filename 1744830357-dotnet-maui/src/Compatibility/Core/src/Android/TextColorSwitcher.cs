using System;
using Android.Content.Res;
using Android.Widget;
using Microsoft.Maui.Graphics;

namespace Microsoft.Maui.Controls.Compatibility.Platform.Android
{
	/// <summary>
	/// Handles color state management for the TextColor property 
	/// for Entry, Button, Picker, TimePicker, and DatePicker
	/// </summary>
	internal class TextColorSwitcher
	{
		static readonly int[] s_disabledColorState = new[] { -global::Android.Resource.Attribute.StateEnabled };

		readonly ColorStateList _defaultTextColors;
		readonly bool _useLegacyColorManagement;
		Color _currentTextColor;

		public TextColorSwitcher(ColorStateList textColors, bool useLegacyColorManagement = true)
		{
			_defaultTextColors = textColors;
			_useLegacyColorManagement = useLegacyColorManagement;
		}

		[PortHandler]
		public void UpdateTextColor(TextView control, Color color, Action<ColorStateList> setColor = null)
		{
			if (color == _currentTextColor)
				return;

			if (setColor == null)
			{
				setColor = control.SetTextColor;
			}

			_currentTextColor = color;

			if (color == null)
			{
				setColor(_defaultTextColors);
			}
			else
			{
				if (_useLegacyColorManagement)
				{
					// Set the new enabled state color, preserving the default disabled state color
					int defaultDisabledColor = _defaultTextColors.GetColorForState(s_disabledColorState, color.ToAndroid());
					ColorStateListExtensions.CreateEditText(color.ToAndroid().ToArgb(), defaultDisabledColor);
				}
				else
				{
					var acolor = color.ToAndroid().ToArgb();
					ColorStateListExtensions.CreateEditText(acolor, acolor);
				}
			}
		}
	}
}