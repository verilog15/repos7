﻿using System;

namespace Microsoft.Maui.Handlers
{
	public partial class EditorHandler : ViewHandler<IEditor, object>
	{
		protected override object CreatePlatformView() => throw new NotImplementedException();

		public static void MapText(IViewHandler handler, IEditor editor) { }
		public static void MapTextColor(IViewHandler handler, IEditor editor) { }
		public static void MapPlaceholder(IViewHandler handler, IEditor editor) { }
		public static void MapPlaceholderColor(IViewHandler handler, IEditor editor) { }
		public static void MapCharacterSpacing(IViewHandler handler, IEditor editor) { }
		public static void MapMaxLength(IViewHandler handler, IEditor editor) { }

		/// <summary>
		/// Maps the abstract <see cref="ITextInput.IsTextPredictionEnabled"/> property to the platform-specific implementations.
		/// </summary>
		/// <param name="handler"> The associated handler.</param>
		/// <param name="editor"> The associated <see cref="IEditor"/> instance.</param>
		public static void MapIsTextPredictionEnabled(IEditorHandler handler, IEditor editor) { }

		/// <summary>
		/// Maps the abstract <see cref="ITextInput.IsSpellCheckEnabled"/> property to the platform-specific implementations.
		/// </summary>
		/// <param name="handler"> The associated handler.</param>
		/// <param name="editor"> The associated <see cref="IEditor"/> instance.</param>
		public static void MapIsSpellCheckEnabled(IEditorHandler handler, IEditor editor) { }
		public static void MapFont(IViewHandler handler, IEditor editor) { }
		public static void MapIsReadOnly(IViewHandler handler, IEditor editor) { }
		public static void MapTextColor(IEditorHandler handler, IEditor editor) { }
		public static void MapHorizontalTextAlignment(IEditorHandler handler, IEditor editor) { }
		public static void MapVerticalTextAlignment(IEditorHandler handler, IEditor editor) { }
		public static void MapKeyboard(IEditorHandler handler, IEditor editor) { }
		public static void MapCursorPosition(IEditorHandler handler, ITextInput editor) { }
		public static void MapSelectionLength(IEditorHandler handler, ITextInput editor) { }
	}
}
