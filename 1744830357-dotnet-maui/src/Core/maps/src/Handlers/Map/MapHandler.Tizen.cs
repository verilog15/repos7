﻿using System;
using Microsoft.Maui.Handlers;
using NView = Tizen.NUI.BaseComponents.View;

namespace Microsoft.Maui.Maps.Handlers
{
	public partial class MapHandler : ViewHandler<IMap, NView>
	{

		protected override NView CreatePlatformView() => throw new NotImplementedException();

		public static void MapMapType(IMapHandler handler, IMap map) => throw new NotImplementedException();

		public static void MapIsShowingUser(IMapHandler handler, IMap map) => throw new NotImplementedException();

		public static void MapIsScrollEnabled(IMapHandler handler, IMap map) => throw new NotImplementedException();

		public static void MapIsTrafficEnabled(IMapHandler handler, IMap map) => throw new NotImplementedException();

		public static void MapIsZoomEnabled(IMapHandler handler, IMap map) => throw new NotImplementedException();

		public static void MapMoveToRegion(IMapHandler handler, IMap map, object? arg) => throw new NotImplementedException();

		public static void MapPins(IMapHandler handler, IMap map) => throw new NotImplementedException();

		public static void MapElements(IMapHandler handler, IMap map) => throw new NotImplementedException();

		public void UpdateMapElement(IMapElement element) => throw new NotImplementedException();
	}
}
