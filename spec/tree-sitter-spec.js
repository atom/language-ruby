const dedent = require('dedent')

describe('Tree-sitter Ruby grammar', () => {
  beforeEach(async () => {
    atom.config.set('core.useTreeSitterParsers', true)
    await atom.packages.activatePackage('language-ruby')
  })

  it('tokenizes visibility modifiers', async () => {
    const editor = await atom.workspace.open('foo.rb')

    editor.setText(dedent`
      public
      protected
      private

      public def foo; end
      protected def bar; end
      private def baz; end
    `)

    expect(editor.scopeDescriptorForBufferPosition([0, 0]).toString()).toBe(
      '.source.ruby .keyword.other.special-method'
    )
    expect(editor.scopeDescriptorForBufferPosition([1, 0]).toString()).toBe(
      '.source.ruby .keyword.other.special-method'
    )
    expect(editor.scopeDescriptorForBufferPosition([2, 0]).toString()).toBe(
      '.source.ruby .keyword.other.special-method'
    )
    expect(editor.scopeDescriptorForBufferPosition([4, 0]).toString()).toBe(
      '.source.ruby .keyword.other.special-method'
    )
    expect(editor.scopeDescriptorForBufferPosition([5, 0]).toString()).toBe(
      '.source.ruby .keyword.other.special-method'
    )
    expect(editor.scopeDescriptorForBufferPosition([6, 0]).toString()).toBe(
      '.source.ruby .keyword.other.special-method'
    )
  })
})
