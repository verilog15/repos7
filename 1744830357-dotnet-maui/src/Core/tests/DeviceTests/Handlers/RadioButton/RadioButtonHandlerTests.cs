﻿#if !IOS && !MACCATALYST
using System.Threading.Tasks;
using Microsoft.Maui.DeviceTests.Stubs;
using Microsoft.Maui.Handlers;
using Xunit;

namespace Microsoft.Maui.DeviceTests
{
	[Category(TestCategory.RadioButton)]
	public partial class RadioButtonHandlerTests : CoreHandlerTestBase<RadioButtonHandler, RadioButtonStub>
	{
		[Theory(DisplayName = "Background Initializes Correctly")]
		[InlineData(0xFFFF0000)]
		[InlineData(0xFF00FF00)]
		[InlineData(0xFF0000FF)]
		public async Task BackgroundInitializesCorrectly(uint color)
		{
			var expected = Color.FromUint(color);

			var radioButton = new RadioButtonStub()
			{
				IsChecked = true,
				Background = new SolidPaintStub(expected),
			};

			await ValidateHasColor(radioButton, expected);
		}

		[Theory(DisplayName = "IsChecked Initializes Correctly")]
		[InlineData(false)]
		[InlineData(true)]
		public async Task IsCheckedInitializesCorrectly(bool isChecked)
		{
			bool xplatIsChecked = isChecked;

			var radioButton = new RadioButtonStub()
			{
				IsChecked = xplatIsChecked
			};

			bool expectedValue = isChecked;

			var values = await GetValueAsync(radioButton, (handler) =>
			{
				return new
				{
					ViewValue = radioButton.IsChecked,
					PlatformViewValue = GetNativeIsChecked(handler)
				};
			});

			Assert.Equal(xplatIsChecked, values.ViewValue);
			Assert.Equal(expectedValue, values.PlatformViewValue);
		}

		[Category(TestCategory.RadioButton)]
		public class RadioButtonTextStyleTests : TextStyleHandlerTests<RadioButtonHandler, RadioButtonStub>
		{
			protected override void SetText(RadioButtonStub stub)
			{
				stub.Content = "test";
			}
		}
	}
}
#endif