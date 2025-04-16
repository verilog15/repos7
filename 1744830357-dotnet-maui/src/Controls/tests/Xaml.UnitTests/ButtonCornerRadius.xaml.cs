using Microsoft.Maui.Controls.Core.UnitTests;
using NUnit.Framework;

namespace Microsoft.Maui.Controls.Xaml.UnitTests
{
	public partial class ButtonCornerRadius : ContentPage
	{
		public ButtonCornerRadius()
		{
			InitializeComponent();
		}

		public ButtonCornerRadius(bool useCompiledXaml)
		{
			//this stub will be replaced at compile time
		}

		[TestFixture]
		public class Tests
		{
			[TestCase(false)]
			[TestCase(true)]
			public void EscapedStringsAreTreatedAsLiterals(bool useCompiledXaml)
			{
				var layout = new ButtonCornerRadius(useCompiledXaml);
				Assert.AreEqual(0, layout.Button0.CornerRadius);
			}
		}
	}
}
