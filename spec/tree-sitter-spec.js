const dedent = require('dedent')

describe('Tree-sitter Ruby grammar', () => {
  beforeEach(async () => {
    atom.config.set('core.useTreeSitterParsers', true)
    await atom.packages.activatePackage('language-ruby')
  })

  it('tokenizes symbols', async () => {
    const editor = await atom.workspace.open('foo.rb')

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

  it('tokenizes constants', async () => {
    const editor = await atom.workspace.open('foo.rb')

    editor.setText(dedent`
      HELLO = __FILE__.dirname
      ClassName::HELLO
      ENV["ABC"]
    `)

    expect(editor.scopeDescriptorForBufferPosition([0, 1]).toString()).toBe(
      '.source.ruby .variable.constant'
    )

    expect(editor.scopeDescriptorForBufferPosition([0, 10]).toString()).toBe(
      '.source.ruby .support.variable'
    )

    expect(editor.scopeDescriptorForBufferPosition([1, 12]).toString()).toBe(
      '.source.ruby .variable.constant'
    )

    expect(editor.scopeDescriptorForBufferPosition([2, 1]).toString()).toBe(
      '.source.ruby .support.variable'
    )
  })


  it('tokenizes kernel methods', async () => {
    const editor = await atom.workspace.open('foo.rb')
    editor.setText(dedent`
      require 'hello'
      require_relative '.world'

      catch :hello do
        throw :hello
      end

      raise StandardError
      binding.pry
      caller
      puts 'asfd'
    `)

    expect(editor.scopeDescriptorForBufferPosition([0, 1]).toString()).toBe(
      '.source.ruby .support.function.kernel'
    )

    expect(editor.scopeDescriptorForBufferPosition([1, 1]).toString()).toBe(
      '.source.ruby .support.function.kernel'
    )

    expect(editor.scopeDescriptorForBufferPosition([3, 1]).toString()).toBe(
      '.source.ruby .support.function.kernel'
    )

    expect(editor.scopeDescriptorForBufferPosition([4, 3]).toString()).toBe(
      '.source.ruby .support.function.kernel'
    )

    expect(editor.scopeDescriptorForBufferPosition([7, 1]).toString()).toBe(
      '.source.ruby .support.function.kernel'
    )

    expect(editor.scopeDescriptorForBufferPosition([8, 1]).toString()).toBe(
      '.source.ruby .support.function.kernel'
    )

    expect(editor.scopeDescriptorForBufferPosition([8, 1]).toString()).toBe(
      '.source.ruby .support.function.kernel'
    )

    expect(editor.scopeDescriptorForBufferPosition([9, 1]).toString()).toBe(
      '.source.ruby .support.function.kernel'
    )
  })

  it('tokenizes visibility modifiers', async () => {
    const editor = await atom.workspace.open('foo.rb')

    editor.setText(dedent`
      public
      protected
      private
      module_function

      public def foo; end
      protected def bar; end
      private def baz; end
      module_function def quux; end
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
    expect(editor.scopeDescriptorForBufferPosition([3, 0]).toString()).toBe(
      '.source.ruby .keyword.other.special-method'
    )
    expect(editor.scopeDescriptorForBufferPosition([5, 0]).toString()).toBe(
      '.source.ruby .keyword.other.special-method'
    )
    expect(editor.scopeDescriptorForBufferPosition([6, 0]).toString()).toBe(
      '.source.ruby .keyword.other.special-method'
    )
    expect(editor.scopeDescriptorForBufferPosition([7, 0]).toString()).toBe(
      '.source.ruby .keyword.other.special-method'
    )
    expect(editor.scopeDescriptorForBufferPosition([8, 0]).toString()).toBe(
      '.source.ruby .keyword.other.special-method'
    )
  })

  it('tokenizes keyword predicates', async () => {
    const editor = await atom.workspace.open('foo.rb')

    editor.setText(dedent`
      defined?(:thing)
      block_given?
      iterator?
    `)

    expect(editor.scopeDescriptorForBufferPosition([0, 0]).toString()).toBe(
      '.source.ruby .keyword.control'
    )
    expect(editor.scopeDescriptorForBufferPosition([1, 0]).toString()).toBe(
      '.source.ruby .keyword.control'
    )
    expect(editor.scopeDescriptorForBufferPosition([2, 0]).toString()).toBe(
      '.source.ruby .keyword.control'
    )
  })

  it('tokenizes alias definitions', async () => {
    const editor = await atom.workspace.open('foo.rb')

    editor.setText(dedent`
      alias_method :name, :full_name
      alias name full_name
    `)

    expect(editor.scopeDescriptorForBufferPosition([0, 0]).toString()).toBe(
      '.source.ruby .keyword.control'
    )
    expect(editor.scopeDescriptorForBufferPosition([1, 0]).toString()).toBe(
      '.source.ruby .keyword.control'
    )
  })

  it('tokenizes keywords', async () => {
    const editor = await atom.workspace.open('foo.rb')

    editor.setText(dedent`
      super
      undef foo
    `)

    expect(editor.scopeDescriptorForBufferPosition([0, 0]).toString()).toBe(
      '.source.ruby .keyword.control'
    )

    expect(editor.scopeDescriptorForBufferPosition([1, 0]).toString()).toBe(
      '.source.ruby .keyword.control'
    )
  })

  it('tokenizes variable in assignment expressions', async () => {
    const editor = await atom.workspace.open('foo.rb')
    editor.setText(dedent`
      a = 10
    `)

    expect(editor.scopeDescriptorForBufferPosition([0, 0]).toString()).toBe(
      '.source.ruby .variable'
    )
  })

  it('does not tokenizes method call in assignment expressions', async () => {
    const editor = await atom.workspace.open('foo.rb')
    editor.setText(dedent`
      foo() = 10
    `)

    expect(editor.scopeDescriptorForBufferPosition([0, 0]).toString()).not.toBe(
      '.source.ruby .variable'
    )
  })

  it('tokenizes lambdas', async () => {
    const editor = await atom.workspace.open('foo.rb')
    editor.setText(dedent`
      foo 'bar', ->(hello) { puts hello }

      lambda { |hello|
        puts hello
      }
    `)

    expect(editor.scopeDescriptorForBufferPosition([0, 12]).toString()).toBe(
      '.source.ruby .support.function.kernel'
    )

    expect(editor.scopeDescriptorForBufferPosition([0, 15]).toString()).toBe(
      '.source.ruby .variable.other.block'
    )

    expect(editor.scopeDescriptorForBufferPosition([2, 1]).toString()).toBe(
      '.source.ruby .support.function.kernel'
    )

    expect(editor.scopeDescriptorForBufferPosition([2, 11]).toString()).toBe(
      '.source.ruby .variable.other.block'
    )
  })

  it('tokenizes special methods', async () => {
    const editor = await atom.workspace.open('foo.rb')
    editor.setText(dedent`
      include HelloWorld
      extend FooBar
    `)

    expect(editor.scopeDescriptorForBufferPosition([0, 1]).toString()).toBe(
      '.source.ruby .keyword.other.special-method'
    )

    expect(editor.scopeDescriptorForBufferPosition([1, 1]).toString()).toBe(
      '.source.ruby .keyword.other.special-method'
    )
  })

  it('tokenizes attr accessors', async () => {
    const editor = await atom.workspace.open('foo.rb')
    editor.setText(dedent`
      attr_accessor :hello
      attr_reader :foo
      attr_writer :bar
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
  })
})
