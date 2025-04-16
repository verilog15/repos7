using Microsoft.Maui.Controls.Core.UnitTests;
using NUnit.Framework;

namespace Microsoft.Maui.Controls.Xaml.UnitTests
{
	public partial class LabelHtml : ContentPage
	{
		public LabelHtml() => InitializeComponent();
		public LabelHtml(bool useCompiledXaml)
		{
			//this stub will be replaced at compile time
		}

		[TestFixture]
		class Tests
		{
			[Test]
			public void HtmlInCDATA([Values(true, false)] bool useCompiledXaml)
			{
				var html = "<h1>Hello World!</h1><br/>SecondLine";
				var layout = new LabelHtml(useCompiledXaml);
				Assert.That(layout.label0.Text, Is.EqualTo(html));
				Assert.That(layout.label1.Text, Is.EqualTo(html));
				Assert.That(layout.label2.Text, Is.EqualTo(html));
				Assert.That(layout.label3.Text, Is.EqualTo(html));
				Assert.That(layout.label4.Text, Is.EqualTo(html));
			}
		}
	}
}