﻿#nullable disable
using Microsoft.Maui.Controls.Platform;

namespace Microsoft.Maui.Controls
{
	public partial class SearchBar
	{
		public static void MapText(SearchBarHandler handler, SearchBar searchBar) =>
			MapText((ISearchBarHandler)handler, searchBar);

		public static void MapText(ISearchBarHandler handler, SearchBar searchBar)
		{
			Platform.SearchViewExtensions.UpdateText(handler.PlatformView, searchBar);
		}
	}
}
