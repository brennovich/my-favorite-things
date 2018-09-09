import net.ceedubs.sbtctags.CtagsKeys

CtagsKeys.ctagsParams ~= (default => default.copy(tagFileName = "./.git/tags-deps"))
