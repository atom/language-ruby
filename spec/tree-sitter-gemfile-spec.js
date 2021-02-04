const dedent = require('dedent')

describe('Tree-sitter Gemfile grammar', () => {
  beforeEach(async () => {
    atom.config.set('core.useTreeSitterParsers', true)
    await atom.packages.activatePackage('language-ruby')
  })

  it('tokenizes ruby code', async () => {
    const editor = await atom.workspace.open('Gemfile')

    editor.setText(dedent`
      :foo
      %i(foo)
    `)

    expect(editor.scopeDescriptorForBufferPosition([0, 1]).toString()).toBe(
      '.source.ruby .constant.other.symbol'
    )

    expect(editor.scopeDescriptorForBufferPosition([1, 3]).toString()).toBe(
      '.source.ruby .constant.other.symbol'
    )
  })

  it('tokenizes Gemfile specific code', async () => {
    const editor = await atom.workspace.open('Gemfile')

    editor.setText(dedent`
      source 'https://rubygems.org'
      ruby '2.5.1'
      gem 'rails', '~> 5.2', '< 6.0'

      group :development, :test do
        gem 'pry'
      end

      eval_gemfile 'Gemfile.local'
    `)

    expect(editor.scopeDescriptorForBufferPosition([0, 1]).toString()).toBe(
      '.source.ruby .keyword.other.special-method'
    )

    expect(editor.scopeDescriptorForBufferPosition([1, 1]).toString()).toBe(
      '.source.ruby .keyword.other.special-method'
    )

    expect(editor.scopeDescriptorForBufferPosition([2, 1]).toString()).toBe(
      '.source.ruby .keyword.other.special-method'
    )

    expect(editor.scopeDescriptorForBufferPosition([4, 1]).toString()).toBe(
      '.source.ruby .keyword.other.special-method'
    )

    expect(editor.scopeDescriptorForBufferPosition([5, 3]).toString()).toBe(
      '.source.ruby .keyword.other.special-method'
    )

    expect(editor.scopeDescriptorForBufferPosition([8, 1]).toString()).toBe(
      '.source.ruby .keyword.other.special-method'
    )
  })
})
