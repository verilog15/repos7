using System.Collections;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.Maui.Controls.Compatibility.Platform.UWP;
using Microsoft.Maui.Dispatching;
using Microsoft.Maui.Graphics;
using Microsoft.Maui.Platform;
using Microsoft.UI.Xaml.Controls;
using Microsoft.UI.Xaml.Media;
using NUnit.Framework;
using WBorder = Microsoft.UI.Xaml.Controls.Border;
using WColor = Windows.UI.Color;
using WSolidColorBrush = Microsoft.UI.Xaml.Media.SolidColorBrush;

namespace Microsoft.Maui.Controls.Compatibility.Platform.UAP.UnitTests
{
	[TestFixture]
	public class BackgroundColorTests : PlatformTestFixture
	{
		static IEnumerable TestCases
		{
			get
			{
				// SearchBar is currently busted; when 8773 gets merged we can stop filtering it
				foreach (var element in BasicViews
					.Where(v => !(v is SearchBar))
					.Where(v => !(v is Frame)))
				{
					element.BackgroundColor = Colors.AliceBlue;
					yield return CreateTestCase(element);
				}
			}
		}

		WColor GetBackgroundColor(Control control)
		{
			if (control is FormsButton button)
			{
				return (button.BackgroundColor as WSolidColorBrush).Color;
			}

			if (control is StepperControl stepper)
			{
				return stepper.ButtonBackgroundColor.ToWindowsColor();
			}

			return (control.Background as WSolidColorBrush).Color;
		}

		WColor GetBackgroundColor(Panel panel)
		{
			return (panel.Background as WSolidColorBrush).Color;
		}

		WColor GetBackgroundColor(WBorder border)
		{
			return (border.Background as WSolidColorBrush).Color;
		}

		async Task<WColor> GetNativeColor(View view)
		{
			return await view.Dispatcher.DispatchAsync(() =>
			{
				var control = GetNativeControl(view);

				if (control != null)
				{
					return GetBackgroundColor(control);
				}

				var border = GetBorder(view);

				if (border != null)
				{
					return GetBackgroundColor(border);
				}

				var panel = GetPanel(view);
				return GetBackgroundColor(panel);
			});
		}

		[Test, TestCaseSource(nameof(TestCases))]
		[Description("View background color should match renderer background color")]
		public async Task BackgroundColorConsistent(View view)
		{
			var nativeColor = await GetNativeColor(view);
			var formsColor = view.BackgroundColor.ToWindowsColor();
			Assert.That(nativeColor, Is.EqualTo(formsColor));
		}

		[Test, Category("BackgroundColor"), Category("Frame")]
		[Description("Frame background color should match renderer background color")]
		public async Task FrameBackgroundColorConsistent()
		{
			var frame = new Frame() { BackgroundColor = Colors.Orange };
			var expectedColor = frame.BackgroundColor.ToWindowsColor();

			var actualColor = await frame.Dispatcher.DispatchAsync(() =>
			{
				var renderer = GetRenderer(frame);
				var nativeElement = renderer.GetNativeElement() as WBorder;

				var backgroundBrush = nativeElement.Background as WSolidColorBrush;
				return backgroundBrush.Color;
			});

			Assert.That(actualColor, Is.EqualTo(expectedColor));
		}
	}
}
