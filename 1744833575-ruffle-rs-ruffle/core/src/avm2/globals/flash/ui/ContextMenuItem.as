package flash.ui
{
    import flash.display.NativeMenuItem;

    public final class ContextMenuItem extends NativeMenuItem
    {
        public function ContextMenuItem(
            caption:String,
            separatorBefore:Boolean = false,
            enabled:Boolean = true,
            visible:Boolean = true
        )
        {
            this.caption = caption;
            this.separatorBefore = separatorBefore;
            this.enabled = enabled;
            this.visible = visible;
        }

        public function clone(): ContextMenuItem
        {
            return new ContextMenuItem(this.caption, this.separatorBefore, this.enabled, this.visible);
        }

        [Ruffle(NativeAccessible)]
        public var caption: String;

        [Ruffle(NativeAccessible)]
        public var separatorBefore: Boolean;

        [Ruffle(NativeAccessible)]
        public var visible: Boolean;
    }
}
