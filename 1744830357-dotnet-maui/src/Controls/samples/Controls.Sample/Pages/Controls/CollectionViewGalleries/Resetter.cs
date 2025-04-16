﻿using Microsoft.Maui.Controls;

namespace Maui.Controls.Sample.Pages.CollectionViewGalleries
{
	internal class Resetter : MultiTestObservableCollectionModifier
	{
		public Resetter(CollectionView cv) : base(cv, "Reset")
		{
		}

		protected override void ModifyObservableCollection(MultiTestObservableCollection<CollectionViewGalleryTestItem> observableCollection, params int[] indexes)
		{
			observableCollection.TestReset();
		}
	}
}