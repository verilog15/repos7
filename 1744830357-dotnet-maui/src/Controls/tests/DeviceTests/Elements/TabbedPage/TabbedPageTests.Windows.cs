﻿using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Maui;
using Microsoft.Maui.Controls;
using Microsoft.Maui.Controls.Handlers;
using Microsoft.Maui.DeviceTests.Stubs;
using Microsoft.Maui.Graphics;
using Microsoft.Maui.Handlers;
using Microsoft.Maui.Hosting;
using Microsoft.Maui.Platform;
using Xunit;
using WFrameworkElement = Microsoft.UI.Xaml.FrameworkElement;
using WSolidColorBrush = Microsoft.UI.Xaml.Media.SolidColorBrush;

namespace Microsoft.Maui.DeviceTests
{

	[Category(TestCategory.TabbedPage)]
	public partial class TabbedPageTests : ControlsHandlerTestBase
	{
		[Fact(DisplayName = "Toolbar Visible When Pushing To TabbedPage")]
		public async Task ToolbarVisibleWhenPushingToTabbedPage()
		{
			SetupBuilder();
			var navPage = new NavigationPage(new ContentPage()) { Title = "App Page" };

			await CreateHandlerAndAddToWindow<WindowHandlerStub>(new Window(navPage), async (handler) =>
			{
				// When the current active page is a TabbedPage then
				// we put to toolbar inside the PaneFooter so it's
				// to the right of the tabs

				await navPage.PushAsync(CreateBasicTabbedPage());
				var navView = GetMauiNavigationView(handler.MauiContext);
				var header = (WFrameworkElement)navView.PaneFooter;
				Assert.NotNull(header);
				Assert.True(header.ActualHeight > 0);
				Assert.True(header.ActualWidth > 0);
				await navPage.PopAsync();
				header = (WFrameworkElement)navView.Header;
				Assert.NotNull(header);
				Assert.True(header.ActualHeight > 0);
				Assert.True(header.ActualWidth > 0);
				await navPage.PushAsync(CreateBasicTabbedPage());
				header = (WFrameworkElement)navView.PaneFooter;
				Assert.NotNull(header);
				Assert.True(header.ActualHeight > 0);
				Assert.True(header.ActualWidth > 0);
			});
		}

		[Fact(DisplayName = "TabbedPage Disconnects")]
		public async Task TabbedViewHandlerDisconnects()
		{
			SetupBuilder();
			var tabbedPage = CreateBasicTabbedPage();

			await CreateHandlerAndAddToWindow<TabbedViewHandler>(tabbedPage, (handler) =>
			{
				// Validate that no exceptions are thrown
				((IElementHandler)handler).DisconnectHandler();
				return Task.CompletedTask;
			});
		}

		[Fact(DisplayName = "Swapping Root Window Content for New Tabbed Page")]
		public async Task SwapWindowContentForNewTabbedPage()
		{
			SetupBuilder();
			var window = new Window()
			{
				Page = CreateBasicTabbedPage()
			};

			await CreateHandlerAndAddToWindow<WindowHandlerStub>(window, async windowHandler =>
			{
				window.Page.Handler.DisconnectHandler();

				// Swap out main page 
				window.Page = CreateBasicTabbedPage();

				// wait for new handler to finish loading
				await ((IPlatformViewHandler)window.Page.Handler).PlatformView.OnLoadedAsync();
				var navView = GetMauiNavigationView(window.Page.Handler.MauiContext);

				// make sure root view is displaying as top tabs
				Assert.Equal(UI.Xaml.Controls.NavigationViewPaneDisplayMode.Top, navView.PaneDisplayMode);
			});
		}

		[Fact(DisplayName = "Tab Title")]
		public async Task TabTitle()
		{
			SetupBuilder();
			await CreateHandlerAndAddToWindow<TabbedViewHandler>(CreateBasicTabbedPage(), handler =>
			{
				var navView = GetMauiNavigationView(handler.MauiContext);
				var navItem = GetNavigationViewItems(navView).ToList()[0];
				Assert.Equal("Page 1", navItem.Content);
				(handler.VirtualView as TabbedPage).Children[0].Title = "New Page Name";
				Assert.Equal("New Page Name", navItem.Content);
				return Task.CompletedTask;
			});
		}

		[Fact(DisplayName = "Adding and Removing Pages Propagates Correctly")]
		public async Task AddingAndRemovingPagesPropagatesCorrectly()
		{
			SetupBuilder();
			await CreateHandlerAndAddToWindow<TabbedViewHandler>(CreateBasicTabbedPage(), async handler =>
			{
				var navView = GetMauiNavigationView(handler.MauiContext);
				var items = GetNavigationViewItems(navView).ToList();
				Assert.Single(items);
				(handler.VirtualView as TabbedPage).Children.Add(new ContentPage());

				// Wait for the navitem to propagate
				await Task.Delay(100);
				items = GetNavigationViewItems(navView).ToList();
				Assert.Equal(2, items.Count);
				(handler.VirtualView as TabbedPage).Children.RemoveAt(1);

				// Wait for the navitem to propagate
				await Task.Delay(100);
				items = GetNavigationViewItems(navView).ToList();
				Assert.Single(items);
			});
		}

		[Fact(DisplayName = "Selected Item Changed Propagates to CurrentPage")]
		public async Task SelectedItemChangedPropagatesToCurrentPage()
		{
			SetupBuilder();

			var tabbedPage = CreateBasicTabbedPage();
			tabbedPage.Children.Add(new ContentPage());



			await CreateHandlerAndAddToWindow<TabbedViewHandler>(tabbedPage, handler =>
			{
				var navView = GetMauiNavigationView(handler.MauiContext);
				var secondItem = (navView.MenuItemsSource as IEnumerable<NavigationViewItemViewModel>).Skip(1).FirstOrDefault();
				navView.SelectedItem = secondItem;

				Assert.Equal(tabbedPage.CurrentPage, tabbedPage.Children[1]);
				return Task.CompletedTask;
			});
		}

		MauiNavigationView GetMauiNavigationView(TabbedPage tabbedPage)
		{
			return (tabbedPage.Handler as IPlatformViewHandler)
				.PlatformView
				.GetParentOfType<MauiNavigationView>();
		}

		async Task ValidateTabBarIconColor(
			TabbedPage tabbedPage,
			string tabText,
			Color iconColor,
			bool hasColor)
		{
			if (hasColor)
			{
				await AssertionExtensions.AssertTabItemIconContainsColor(
					GetMauiNavigationView(tabbedPage),
					tabText, iconColor, tabbedPage.FindMauiContext());
			}
			else
			{
				await AssertionExtensions.AssertTabItemIconDoesNotContainColor(
					GetMauiNavigationView(tabbedPage),
					tabText, iconColor, tabbedPage.FindMauiContext());
			}
		}

		async Task ValidateTabBarTextColor(
			TabbedPage tabbedPage,
			string tabText,
			Color iconColor,
			bool hasColor)
		{
			if (hasColor)
			{
				await AssertionExtensions.AssertTabItemTextContainsColor(
					GetMauiNavigationView(tabbedPage),
					tabText, iconColor, tabbedPage.FindMauiContext());
			}
			else
			{
				await AssertionExtensions.AssertTabItemTextDoesNotContainColor(
					GetMauiNavigationView(tabbedPage),
					tabText, iconColor, tabbedPage.FindMauiContext());
			}
		}
	}
}
