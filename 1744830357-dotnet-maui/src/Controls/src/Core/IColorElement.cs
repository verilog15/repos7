#nullable disable
using Microsoft.Maui.Graphics;

namespace Microsoft.Maui.Controls
{
	interface IColorElement
	{
		//note to implementor: implement this property publicly
		Color Color { get; }
	}
}