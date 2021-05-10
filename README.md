This is an work-in-progress experiment on building a document editor similar to Bear, Notion, Notes.app, Craft, Dropbox Paper, and others. I open-sourced it in case anyone is curious to follow along. after my [initial tweets](https://twitter.com/zachwaugh/status/1390325967596527618?s=20). I'm not looking for contributions at this point, since I don't really know where this is going to go, if anywhere.

I have ideas for a few apps I'd like to build around this kind of document, so my main goal is to build the core editor first, and then extract it to a framework to build a separate app around it.

## Architecture

The core of the app is a `Document` composed of an array of `Block`. Each `Block` can have a different content type and renders as its own cell/row in a `UICollectionView` or `UITableView`. See tweet above for discussion of the merits of this approach vs using a `UITextView` based approach. This seemed the most flexible long-term, at the cost of losing some text editing niceties.

### Block types

- [x] Paragraph/Text
- [x] Heading
- [x] Todo
- [x] Bulleted list item
- [x] Numbered listed item
- [ ] Blockquote
- [ ] Divider
- [ ] Image
- [ ] Attachment


## Roadmap

- [ ] Toolbar
- [ ] Persistence
- [ ] Inline text formatting (bold, italic, underline, strikethrough, link)
- [ ] Indent/dedent
- [ ] Improved keyboard navigation
- [ ] Swipe actions on rows
- [ ] Drag-and-drop
- [ ] Finish block types
- [ ] Import from Markdown
- [ ] Export to Markdown

## License

MIT


## Author
- Zach Waugh
- [@zachwaugh](https://twitter.com/zachwaugh)
- [https://zachwaugh.com](https://zachwaugh.com)