using Microsoft.Maui.ApplicationModel;
using Microsoft.Maui.Controls.Core.UnitTests;
using Microsoft.Maui.Devices;
using Microsoft.Maui.Graphics;
using NUnit.Framework;

namespace Microsoft.Maui.Controls.Xaml.UnitTests
{
	[TestFixture]
	public class OnAppThemeTests : BaseTestFixture
	{
		MockAppInfo mockAppInfo;
		MockApplication mockApp;

		[SetUp]
		public override void Setup()
		{
			base.Setup();
			AppInfo.SetCurrent(mockAppInfo = new MockAppInfo());
			Application.Current = mockApp = new MockApplication();
		}

		[TearDown]
		public override void TearDown()
		{
			Application.Current = null;
			AppInfo.SetCurrent(null);
			base.TearDown();
		}

		[Test]
		public void OnAppThemeExtensionLightDarkColor()
		{
			var xaml = @"
			<Label 
			xmlns=""http://schemas.microsoft.com/dotnet/2021/maui""
			xmlns:x=""http://schemas.microsoft.com/winfx/2009/xaml"" TextColor=""{AppThemeBinding Light = Green, Dark = Red}
			"">This text is green or red depending on Light (or default) or Dark</Label>";

			SetAppTheme(AppTheme.Light);
			var label = new Label().LoadFromXaml(xaml);
			Assert.AreEqual(Colors.Green, label.TextColor);

			SetAppTheme(AppTheme.Dark);
			label = new Label().LoadFromXaml(xaml);
			Assert.AreEqual(Colors.Red, label.TextColor);
		}

		[Test]
		public void OnAppThemeLightDarkColor()
		{
			var xaml = @"
			<Label
			xmlns=""http://schemas.microsoft.com/dotnet/2021/maui""
			xmlns:x=""http://schemas.microsoft.com/winfx/2009/xaml""
			Text=""This text is green or red depending on Light(or default) or Dark"">
                <Label.TextColor>
                    <AppThemeBinding Light=""Green"" Dark=""Red"" />
				</Label.TextColor>
			</Label> ";

			SetAppTheme(AppTheme.Light);
			var label = new Label().LoadFromXaml(xaml);
			Assert.AreEqual(Colors.Green, label.TextColor);

			SetAppTheme(AppTheme.Dark);
			label = new Label().LoadFromXaml(xaml);
			Assert.AreEqual(Colors.Red, label.TextColor);
		}

		[Test]
		public void OnAppThemeUnspecifiedThemeDefaultsToLightColor()
		{
			var xaml = @"
			<Label
			xmlns=""http://schemas.microsoft.com/dotnet/2021/maui""
			xmlns:x=""http://schemas.microsoft.com/winfx/2009/xaml""
			Text=""This text is green or red depending on Light(or default) or Dark"">
                <Label.TextColor>
                    <AppThemeBinding Light=""Green"" Dark=""Red"" />
				</Label.TextColor>
			</Label> ";

			SetAppTheme(AppTheme.Unspecified);
			var label = new Label().LoadFromXaml(xaml);
			Assert.AreEqual(Colors.Green, label.TextColor);
		}

		[Test]
		public void OnAppThemeUnspecifiedLightColorDefaultsToDefault()
		{
			var xaml = @"
			<Label
			xmlns=""http://schemas.microsoft.com/dotnet/2021/maui""
			xmlns:x=""http://schemas.microsoft.com/winfx/2009/xaml""
			Text=""This text is green or red depending on Light(or default) or Dark"">
                <Label.TextColor>
                    <AppThemeBinding Default=""Green"" Dark=""Red"" />
				</Label.TextColor>
			</Label> ";

			SetAppTheme(AppTheme.Light);
			var label = new Label().LoadFromXaml(xaml);
			Assert.AreEqual(Colors.Green, label.TextColor);
		}

		[Test]
		public void AppThemeColorLightDark()
		{
			var xaml = @"
			<Label
			xmlns=""http://schemas.microsoft.com/dotnet/2021/maui""
			xmlns:x=""http://schemas.microsoft.com/winfx/2009/xaml""
			Text=""This text is green or red depending on Light(or default) or Dark"">
                <Label.TextColor>
                    <AppThemeBinding Light=""Green"" Dark=""Red"" />
				</Label.TextColor>
			</Label> ";

			SetAppTheme(AppTheme.Light);
			var label = new Label().LoadFromXaml(xaml);
			Assert.AreEqual(Colors.Green, label.TextColor);

			SetAppTheme(AppTheme.Dark);
			label = new Label().LoadFromXaml(xaml);
			Assert.AreEqual(Colors.Red, label.TextColor);
		}

		[Test]
		public void AppThemeColorUnspecifiedThemeDefaultsToLightColor()
		{
			var xaml = @"
			<Label
			xmlns=""http://schemas.microsoft.com/dotnet/2021/maui""
			xmlns:x=""http://schemas.microsoft.com/winfx/2009/xaml""
			Text=""This text is green or red depending on Light(or default) or Dark"">
                <Label.TextColor>
                    <AppThemeBinding Light=""Green"" Dark=""Red"" />
				</Label.TextColor>
			</Label> ";

			SetAppTheme(AppTheme.Unspecified);
			var label = new Label().LoadFromXaml(xaml);
			Assert.AreEqual(Colors.Green, label.TextColor);
		}

		[Test]
		public void AppThemeColorUnspecifiedLightColorDefaultsToDefault()
		{
			var xaml = @"
			<Label
			xmlns=""http://schemas.microsoft.com/dotnet/2021/maui""
			xmlns:x=""http://schemas.microsoft.com/winfx/2009/xaml""
			Text=""This text is green or red depending on Light(or default) or Dark"">
                <Label.TextColor>
                    <AppThemeBinding Default=""Green"" Dark=""Red"" />
				</Label.TextColor>
			</Label> ";

			SetAppTheme(AppTheme.Unspecified);
			var label = new Label().LoadFromXaml(xaml);
			Assert.AreEqual(Colors.Green, label.TextColor);
		}

		void SetAppTheme(AppTheme theme)
		{
			mockAppInfo.RequestedTheme = theme;
			mockApp.NotifyThemeChanged();
		}
	}
}