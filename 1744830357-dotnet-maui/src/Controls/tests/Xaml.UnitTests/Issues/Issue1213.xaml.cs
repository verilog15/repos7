using System;
using System.Collections.Generic;
using Microsoft.Maui.Controls;
using Microsoft.Maui.Dispatching;
using Microsoft.Maui.UnitTests;
using NUnit.Framework;

namespace Microsoft.Maui.Controls.Xaml.UnitTests
{
	public partial class Issue1213 : TabbedPage
	{
		public Issue1213()
		{
			InitializeComponent();
		}

		public Issue1213(bool useCompiledXaml)
		{
			//this stub will be replaced at compile time
		}

		[TestFixture]
		public class Tests
		{
			[SetUp] public void Setup() => DispatcherProvider.SetCurrent(new DispatcherProviderStub());
			[TearDown] public void TearDown() => DispatcherProvider.SetCurrent(null);

			[TestCase(false)]
			[TestCase(true)]
			public void MultiPageAsContentPropertyAttribute(bool useCompiledXaml)
			{
				var page = new Issue1213(useCompiledXaml);
				Assert.AreEqual(2, page.Children.Count);
			}
		}
	}
}