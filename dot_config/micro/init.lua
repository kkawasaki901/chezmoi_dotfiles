local config = import("micro/config")

function markdownNewline(bp)
    local line = bp.Buf:Line(bp.Cursor.Y)
    local prefix = nil

    if bp.Buf.Settings["filetype"] == "markdown" then
        -- "- [ ] " を優先して判定
        prefix = line:match("^(%s*%- %[ %] )")
            or line:match("^(%s*%- )")
    end

    -- カーソルが行の途中にいても、先に行末へ移動
    bp:EndOfLine()
    bp:InsertNewline()

    -- Markdownリストなら同じ記号を挿入
    if prefix ~= nil then
        bp.Buf:Insert(-bp.Cursor.Loc, prefix)
    end

    return true
end

function init()
    config.TryBindKey(
        "Ctrl-j",
        "lua:initlua.markdownNewline",
        true
    )
end
