using System;
using System.Collections.Generic;
using Microsoft.Maui.Controls;
using Microsoft.Maui.Dispatching;
using Microsoft.Maui.UnitTests;
using NUnit.Framework;

namespace Microsoft.Maui.Controls.Xaml.UnitTests
{
	public partial class Bz30684 : ContentPage
	{
		public Bz30684()
		{
			InitializeComponent();
		}

		public Bz30684(bool useCompiledXaml)
		{
			//this stub will be replaced at compile time
		}

		[TestFixture]
		class Tests
		{
			[SetUp] public void Setup() => DispatcherProvider.SetCurrent(new DispatcherProviderStub());
			[TearDown] public void TearDown() => DispatcherProvider.SetCurrent(null);

			[TestCase(true)]
			[TestCase(false)]
			public void XReferenceFindObjectsInParentNamescopes(bool useCompiledXaml)
			{
				var layout = new Bz30684(useCompiledXaml);
				var cell = (TextCell)layout.listView.TemplatedItems.GetOrCreateContent(0, null);
				Assert.AreEqual("Foo", cell.Text);
			}
		}
	}
}