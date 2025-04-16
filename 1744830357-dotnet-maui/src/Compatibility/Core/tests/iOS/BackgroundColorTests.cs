using System.Collections;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.Maui.Controls.Compatibility.Platform.iOS;
using Microsoft.Maui.Graphics;
using Microsoft.Maui.Platform;
using NUnit.Framework;

namespace Microsoft.Maui.Controls.Compatibility.Platform.iOS.UnitTests
{
	[TestFixture]
	public class BackgroundColorTests : PlatformTestFixture
	{
		static IEnumerable TestCases
		{
			get
			{
				foreach (var element in BasicViews
					.Where(e => !(e is Label) && !(e is BoxView) && !(e is Frame)))
				{
					element.BackgroundColor = Colors.AliceBlue;
					yield return new TestCaseData(element)
						.SetCategory(element.GetType().Name);
				}
			}
		}

		[Test, Category("BackgroundColor"), TestCaseSource(nameof(TestCases))]
		[Description("VisualElement background color should match renderer background color")]
		public async Task BackgroundColorConsistent(VisualElement element)
		{
			var expected = element.BackgroundColor.ToPlatform();
			var actual = await GetControlProperty(element, uiview => uiview.BackgroundColor);
			Assert.That(actual, Is.EqualTo(expected));
		}

		[Test, Category("BackgroundColor"), Category("Frame")]
		[Description("Frame background color should match renderer background color")]
		public async Task FrameBackgroundColorConsistent()
		{
			var frame = new Frame { BackgroundColor = Colors.AliceBlue };
			var expectedColor = frame.BackgroundColor.ToPlatform();
			var screenshot = await GetRendererProperty(frame, (ver) => ver.NativeView.ToBitmap(), requiresLayout: true);
			screenshot.AssertColorAtCenter(expectedColor);
		}

		[Test, Category("BackgroundColor"), Category("Label")]
		[Description("Label background color should match renderer background color")]
		public async Task LabelBackgroundColorConsistent()
		{
			var label = new Label { Text = "foo", BackgroundColor = Colors.AliceBlue };
			var expected = label.BackgroundColor.ToPlatform();
			var actual = await GetRendererProperty(label, r => r.NativeView.BackgroundColor);
			Assert.That(actual, Is.EqualTo(expected));
		}

		[Test, Category("BackgroundColor"), Category("BoxView")]
		[Description("BoxView background color should match renderer background color")]
		public async Task BoxViewBackgroundColorConsistent2()
		{
			var boxView = new BoxView { BackgroundColor = Colors.AliceBlue };
			var expectedColor = boxView.BackgroundColor.ToPlatform();
			var screenshot = await GetRendererProperty(boxView, (ver) => ver.NativeView.ToBitmap(), requiresLayout: true);
			screenshot.AssertColorAtCenter(expectedColor);
		}
	}
}