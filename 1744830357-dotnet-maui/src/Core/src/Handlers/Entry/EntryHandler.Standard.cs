﻿using System;

namespace Microsoft.Maui.Handlers
{
	public partial class EntryHandler : ViewHandler<IEntry, object>
	{
		protected override object CreatePlatformView() => throw new NotImplementedException();

		public static void MapText(IEntryHandler handler, IEntry entry) { }
		public static void MapTextColor(IEntryHandler handler, IEntry entry) { }
		public static void MapIsPassword(IEntryHandler handler, IEntry entry) { }
		public static void MapHorizontalTextAlignment(IEntryHandler handler, IEntry entry) { }
		public static void MapVerticalTextAlignment(IEntryHandler handler, IEntry entry) { }

		/// <summary>
		/// Maps the abstract <see cref="ITextInput.IsTextPredictionEnabled"/> property to the platform-specific implementations.
		/// </summary>
		/// <param name="handler"> The associated handler.</param>
		/// <param name="entry"> The associated <see cref="IEntry"/> instance.</param>
		public static void MapIsTextPredictionEnabled(IEntryHandler handler, IEntry entry) { }

		/// <summary>
		/// Maps the abstract <see cref="ITextInput.IsSpellCheckEnabled"/> property to the platform-specific implementations.
		/// </summary>
		/// <param name="handler"> The associated handler.</param>
		/// <param name="entry"> The associated <see cref="IEntry"/> instance.</param>
		public static void MapIsSpellCheckEnabled(IEntryHandler handler, IEntry entry) { }
		public static void MapMaxLength(IEntryHandler handler, IEntry entry) { }
		public static void MapPlaceholder(IEntryHandler handler, IEntry entry) { }
		public static void MapPlaceholderColor(IEntryHandler handler, IEntry entry) { }
		public static void MapIsReadOnly(IEntryHandler handler, IEntry entry) { }
		public static void MapKeyboard(IEntryHandler handler, IEntry entry) { }
		public static void MapFont(IEntryHandler handler, IEntry entry) { }
		public static void MapReturnType(IEntryHandler handler, IEntry entry) { }
		public static void MapClearButtonVisibility(IEntryHandler handler, IEntry entry) { }
		public static void MapCharacterSpacing(IEntryHandler handler, IEntry entry) { }
		public static void MapCursorPosition(IEntryHandler handler, IEntry entry) { }
		public static void MapSelectionLength(IEntryHandler handler, IEntry entry) { }
	}
}