#nullable disable
using System.Collections.ObjectModel;
using Microsoft.Maui.Graphics;

namespace Microsoft.Maui.Controls
{
	public interface IPageController : IVisualElementController
	{
		Rect ContainerArea { get; set; }

		bool IgnoresContainerArea { get; set; }

		ObservableCollection<Element> InternalChildren { get; }

		void SendAppearing();

		void SendDisappearing();
	}
}