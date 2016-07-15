describe "Ruby grammar", ->
  grammar = null

  beforeEach ->
    waitsForPromise ->
      atom.packages.activatePackage("language-ruby")

    runs ->
      grammar = atom.grammars.grammarForScopeName("source.ruby")

  it "parses the grammar", ->
    expect(grammar).toBeTruthy()
    expect(grammar.scopeName).toBe "source.ruby"

  it "tokenizes self", ->
    {tokens} = grammar.tokenizeLine('self')
    expect(tokens[0]).toEqual value: 'self', scopes: ['source.ruby', 'variable.language.self.ruby']

  it "tokenizes special functions", ->
    {tokens} = grammar.tokenizeLine('require "."')
    expect(tokens[0]).toEqual value: 'require', scopes: ['source.ruby', 'meta.require.ruby', 'keyword.other.special-method.ruby']

    {tokens} = grammar.tokenizeLine('Kernel.require "."')
    expect(tokens[1]).toEqual value: '.', scopes: ['source.ruby', 'punctuation.separator.method.ruby']
    expect(tokens[2]).toEqual value: 'require ', scopes: ['source.ruby']

    {tokens} = grammar.tokenizeLine('Kernel::require "."')
    expect(tokens[1]).toEqual value: '::', scopes: ['source.ruby', 'punctuation.separator.method.ruby']
    expect(tokens[2]).toEqual value: 'require ', scopes: ['source.ruby']

    {tokens} = grammar.tokenizeLine('thing&.call')
    expect(tokens[1]).toEqual value: '&.', scopes: ['source.ruby', 'punctuation.separator.method.ruby']
    expect(tokens[2]).toEqual value: 'call', scopes: ['source.ruby']

  it "tokenizes symbols", ->
    {tokens} = grammar.tokenizeLine(':test')
    expect(tokens[0]).toEqual value: ':', scopes: ['source.ruby', 'constant.other.symbol.ruby', 'punctuation.definition.constant.ruby']
    expect(tokens[1]).toEqual value: 'test', scopes: ['source.ruby', 'constant.other.symbol.ruby']

    {tokens} = grammar.tokenizeLine(':$symbol')
    expect(tokens[0]).toEqual value: ':', scopes: ['source.ruby', 'constant.other.symbol.ruby', 'punctuation.definition.constant.ruby']
    expect(tokens[1]).toEqual value: '$symbol', scopes: ['source.ruby', 'constant.other.symbol.ruby']

    {tokens} = grammar.tokenizeLine(':<=>')
    expect(tokens[0]).toEqual value: ':', scopes: ['source.ruby', 'constant.other.symbol.ruby', 'punctuation.definition.constant.ruby']
    expect(tokens[1]).toEqual value: '<=>', scopes: ['source.ruby', 'constant.other.symbol.ruby']

  it "tokenizes symbol as hash key (1.9 syntax)", ->
    {tokens} = grammar.tokenizeLine('foo: 1')
    expect(tokens[0]).toEqual value: 'foo', scopes: ['source.ruby', 'constant.other.symbol.hashkey.ruby']
    expect(tokens[1]).toEqual value: ':', scopes: ['source.ruby', 'constant.other.symbol.hashkey.ruby', 'punctuation.definition.constant.hashkey.ruby']
    expect(tokens[2]).toEqual value: ' ', scopes: ['source.ruby']
    expect(tokens[3]).toEqual value: '1', scopes: ['source.ruby', 'constant.numeric.ruby']

  it "tokenizes symbol as hash key (1.8 syntax)", ->
    {tokens} = grammar.tokenizeLine(':foo => 1')
    expect(tokens[0]).toEqual value: ':', scopes: ['source.ruby', 'constant.other.symbol.hashkey.ruby', 'punctuation.definition.constant.ruby']
    expect(tokens[1]).toEqual value: 'foo', scopes: ['source.ruby', 'constant.other.symbol.hashkey.ruby']
    expect(tokens[2]).toEqual value: ' ', scopes: ['source.ruby']
    expect(tokens[3]).toEqual value: '=>', scopes: ['source.ruby', 'punctuation.separator.key-value']
    expect(tokens[4]).toEqual value: ' ', scopes: ['source.ruby']
    expect(tokens[5]).toEqual value: '1', scopes: ['source.ruby', 'constant.numeric.ruby']

  it "tokenizes :: separators", ->
    {tokens} = grammar.tokenizeLine('File::read "test"')
    expect(tokens[0]).toEqual value: 'File', scopes: ['source.ruby', 'support.class.ruby']
    expect(tokens[1]).toEqual value: '::', scopes: ['source.ruby', 'punctuation.separator.method.ruby']
    expect(tokens[2]).toEqual value: 'read ', scopes: ['source.ruby']

    {tokens} = grammar.tokenizeLine('File:: read "test"')
    expect(tokens[0]).toEqual value: 'File', scopes: ['source.ruby', 'variable.other.constant.ruby']
    expect(tokens[1]).toEqual value: '::', scopes: ['source.ruby', 'punctuation.separator.method.ruby']
    expect(tokens[2]).toEqual value: ' ', scopes: ['source.ruby']
    expect(tokens[3]).toEqual value: 'read ', scopes: ['source.ruby']

    {tokens} = grammar.tokenizeLine('RbConfig::CONFIG')
    expect(tokens[0]).toEqual value: 'RbConfig', scopes: ['source.ruby', 'support.class.ruby']
    expect(tokens[1]).toEqual value: '::', scopes: ['source.ruby', 'punctuation.separator.namespace.ruby']
    expect(tokens[2]).toEqual value: 'CONFIG', scopes: ['source.ruby', 'variable.other.constant.ruby']

    {tokens} = grammar.tokenizeLine('RbConfig:: CONFIG')
    expect(tokens[0]).toEqual value: 'RbConfig', scopes: ['source.ruby', 'variable.other.constant.ruby']
    expect(tokens[1]).toEqual value: '::', scopes: ['source.ruby', 'punctuation.separator.namespace.ruby']
    expect(tokens[2]).toEqual value: ' ', scopes: ['source.ruby']
    expect(tokens[3]).toEqual value: 'CONFIG', scopes: ['source.ruby', 'variable.other.constant.ruby']

  it "tokenizes . separator", ->
    {tokens} = grammar.tokenizeLine('File.read "test"')
    expect(tokens[0]).toEqual value: 'File', scopes: ['source.ruby', 'support.class.ruby']
    expect(tokens[1]).toEqual value: '.', scopes: ['source.ruby', 'punctuation.separator.method.ruby']
    expect(tokens[2]).toEqual value: 'read ', scopes: ['source.ruby']

    {tokens} = grammar.tokenizeLine('File. read "test"')
    expect(tokens[0]).toEqual value: 'File', scopes: ['source.ruby', 'variable.other.constant.ruby']
    expect(tokens[1]).toEqual value: '.', scopes: ['source.ruby', 'punctuation.separator.method.ruby']
    expect(tokens[2]).toEqual value: ' ', scopes: ['source.ruby']
    expect(tokens[3]).toEqual value: 'read ', scopes: ['source.ruby']

  it "tokenizes %() style strings", ->
    {tokens} = grammar.tokenizeLine('%(te(s)t)')

    expect(tokens[0]).toEqual value: '%(', scopes: ['source.ruby', 'string.quoted.other.interpolated.ruby', 'punctuation.definition.string.begin.ruby']
    expect(tokens[1]).toEqual value: 'te', scopes: ['source.ruby', 'string.quoted.other.interpolated.ruby']
    expect(tokens[2]).toEqual value: '(', scopes: ['source.ruby', 'string.quoted.other.interpolated.ruby', 'punctuation.section.scope.ruby']
    expect(tokens[3]).toEqual value: 's', scopes: ['source.ruby', 'string.quoted.other.interpolated.ruby']
    expect(tokens[4]).toEqual value: ')', scopes: ['source.ruby', 'string.quoted.other.interpolated.ruby', 'punctuation.section.scope.ruby']
    expect(tokens[5]).toEqual value: 't', scopes: ['source.ruby', 'string.quoted.other.interpolated.ruby']
    expect(tokens[6]).toEqual value: ')', scopes: ['source.ruby', 'string.quoted.other.interpolated.ruby', 'punctuation.definition.string.end.ruby']

  it "tokenizes %[] style strings", ->
    {tokens} = grammar.tokenizeLine('%[te[s]t]')

    expect(tokens[0]).toEqual value: '%[', scopes: ['source.ruby', 'string.quoted.other.interpolated.ruby', 'punctuation.definition.string.begin.ruby']
    expect(tokens[1]).toEqual value: 'te', scopes: ['source.ruby', 'string.quoted.other.interpolated.ruby']
    expect(tokens[2]).toEqual value: '[', scopes: ['source.ruby', 'string.quoted.other.interpolated.ruby', 'punctuation.section.scope.ruby']
    expect(tokens[3]).toEqual value: 's', scopes: ['source.ruby', 'string.quoted.other.interpolated.ruby']
    expect(tokens[4]).toEqual value: ']', scopes: ['source.ruby', 'string.quoted.other.interpolated.ruby', 'punctuation.section.scope.ruby']
    expect(tokens[5]).toEqual value: 't', scopes: ['source.ruby', 'string.quoted.other.interpolated.ruby']
    expect(tokens[6]).toEqual value: ']', scopes: ['source.ruby', 'string.quoted.other.interpolated.ruby', 'punctuation.definition.string.end.ruby']

  it "tokenizes %{} style strings", ->
    {tokens} = grammar.tokenizeLine('%{te{s}t}')

    expect(tokens[0]).toEqual value: '%{', scopes: ['source.ruby', 'string.quoted.other.interpolated.ruby', 'punctuation.definition.string.begin.ruby']
    expect(tokens[1]).toEqual value: 'te', scopes: ['source.ruby', 'string.quoted.other.interpolated.ruby']
    expect(tokens[2]).toEqual value: '{', scopes: ['source.ruby', 'string.quoted.other.interpolated.ruby', 'punctuation.section.scope.ruby']
    expect(tokens[3]).toEqual value: 's', scopes: ['source.ruby', 'string.quoted.other.interpolated.ruby']
    expect(tokens[4]).toEqual value: '}', scopes: ['source.ruby', 'string.quoted.other.interpolated.ruby', 'punctuation.section.scope.ruby']
    expect(tokens[5]).toEqual value: 't', scopes: ['source.ruby', 'string.quoted.other.interpolated.ruby']
    expect(tokens[6]).toEqual value: '}', scopes: ['source.ruby', 'string.quoted.other.interpolated.ruby', 'punctuation.definition.string.end.ruby']

  it "tokenizes %<> style strings", ->
    {tokens} = grammar.tokenizeLine('%<te<s>t>')

    expect(tokens[0]).toEqual value: '%<', scopes: ['source.ruby', 'string.quoted.other.interpolated.ruby', 'punctuation.definition.string.begin.ruby']
    expect(tokens[1]).toEqual value: 'te', scopes: ['source.ruby', 'string.quoted.other.interpolated.ruby']
    expect(tokens[2]).toEqual value: '<', scopes: ['source.ruby', 'string.quoted.other.interpolated.ruby', 'punctuation.section.scope.ruby']
    expect(tokens[3]).toEqual value: 's', scopes: ['source.ruby', 'string.quoted.other.interpolated.ruby']
    expect(tokens[4]).toEqual value: '>', scopes: ['source.ruby', 'string.quoted.other.interpolated.ruby', 'punctuation.section.scope.ruby']
    expect(tokens[5]).toEqual value: 't', scopes: ['source.ruby', 'string.quoted.other.interpolated.ruby']
    expect(tokens[6]).toEqual value: '>', scopes: ['source.ruby', 'string.quoted.other.interpolated.ruby', 'punctuation.definition.string.end.ruby']

  it "tokenizes %~~ style strings", ->
    {tokens} = grammar.tokenizeLine('%~te\\~s\\~t~')

    expect(tokens[0]).toEqual value: '%~', scopes: ['source.ruby', 'string.quoted.other.interpolated.ruby', 'punctuation.definition.string.begin.ruby']
    expect(tokens[1]).toEqual value: 'te', scopes: ['source.ruby', 'string.quoted.other.interpolated.ruby']
    expect(tokens[2]).toEqual value: '\\~', scopes: ['source.ruby', 'string.quoted.other.interpolated.ruby', 'constant.character.escape.ruby']
    expect(tokens[3]).toEqual value: 's', scopes: ['source.ruby', 'string.quoted.other.interpolated.ruby']
    expect(tokens[4]).toEqual value: '\\~', scopes: ['source.ruby', 'string.quoted.other.interpolated.ruby', 'constant.character.escape.ruby']
    expect(tokens[5]).toEqual value: 't', scopes: ['source.ruby', 'string.quoted.other.interpolated.ruby']
    expect(tokens[6]).toEqual value: '~', scopes: ['source.ruby', 'string.quoted.other.interpolated.ruby', 'punctuation.definition.string.end.ruby']

  it "tokenizes %Q() style strings", ->
    {tokens} = grammar.tokenizeLine('%Q(te(s)t)')

    expect(tokens[0]).toEqual value: '%Q(', scopes: ['source.ruby', 'string.quoted.other.interpolated.ruby', 'punctuation.definition.string.begin.ruby']
    expect(tokens[1]).toEqual value: 'te', scopes: ['source.ruby', 'string.quoted.other.interpolated.ruby']
    expect(tokens[2]).toEqual value: '(', scopes: ['source.ruby', 'string.quoted.other.interpolated.ruby', 'punctuation.section.scope.ruby']
    expect(tokens[3]).toEqual value: 's', scopes: ['source.ruby', 'string.quoted.other.interpolated.ruby']
    expect(tokens[4]).toEqual value: ')', scopes: ['source.ruby', 'string.quoted.other.interpolated.ruby', 'punctuation.section.scope.ruby']
    expect(tokens[5]).toEqual value: 't', scopes: ['source.ruby', 'string.quoted.other.interpolated.ruby']
    expect(tokens[6]).toEqual value: ')', scopes: ['source.ruby', 'string.quoted.other.interpolated.ruby', 'punctuation.definition.string.end.ruby']

  it "tokenizes %x!! style strings", ->
    {tokens} = grammar.tokenizeLine('%x!\#\{"l" + "s"\}!')

    expect(tokens[0]).toEqual value: '%x!', scopes: ['source.ruby', 'string.quoted.other.interpolated.ruby', 'punctuation.definition.string.begin.ruby']
    expect(tokens[1]).toEqual value: '#{', scopes: ['source.ruby', 'string.quoted.other.interpolated.ruby', 'meta.embedded.line.ruby', 'punctuation.section.embedded.begin.ruby']
    expect(tokens[11]).toEqual value: '}', scopes: ['source.ruby', 'string.quoted.other.interpolated.ruby', 'meta.embedded.line.ruby', 'punctuation.section.embedded.end.ruby']
    expect(tokens[12]).toEqual value: '!', scopes: ['source.ruby', 'string.quoted.other.interpolated.ruby', 'punctuation.definition.string.end.ruby']

  it "tokenizes regular expressions", ->
    {tokens} = grammar.tokenizeLine('/test/')

    expect(tokens[0]).toEqual value: '/', scopes: ['source.ruby', 'string.regexp.interpolated.ruby', 'punctuation.section.regexp.ruby']
    expect(tokens[1]).toEqual value: 'test', scopes: ['source.ruby', 'string.regexp.interpolated.ruby']
    expect(tokens[2]).toEqual value: '/', scopes: ['source.ruby', 'string.regexp.interpolated.ruby', 'punctuation.section.regexp.ruby']

    {tokens} = grammar.tokenizeLine('/{w}/')

    expect(tokens[0]).toEqual value: '/', scopes: ['source.ruby', 'string.regexp.interpolated.ruby', 'punctuation.section.regexp.ruby']
    expect(tokens[1]).toEqual value: '{w}', scopes: ['source.ruby', 'string.regexp.interpolated.ruby']
    expect(tokens[2]).toEqual value: '/', scopes: ['source.ruby', 'string.regexp.interpolated.ruby', 'punctuation.section.regexp.ruby']

    {tokens} = grammar.tokenizeLine('a_method /test/')

    expect(tokens[0]).toEqual value: 'a_method ', scopes: ['source.ruby']
    expect(tokens[1]).toEqual value: '/', scopes: ['source.ruby', 'string.regexp.interpolated.ruby', 'punctuation.section.regexp.ruby']
    expect(tokens[2]).toEqual value: 'test', scopes: ['source.ruby', 'string.regexp.interpolated.ruby']
    expect(tokens[3]).toEqual value: '/', scopes: ['source.ruby', 'string.regexp.interpolated.ruby', 'punctuation.section.regexp.ruby']

    {tokens} = grammar.tokenizeLine('a_method(/test/)')

    expect(tokens[0]).toEqual value: 'a_method', scopes: ['source.ruby']
    expect(tokens[1]).toEqual value: '(', scopes: ['source.ruby', 'punctuation.section.function.ruby']
    expect(tokens[2]).toEqual value: '/', scopes: ['source.ruby', 'string.regexp.interpolated.ruby', 'punctuation.section.regexp.ruby']
    expect(tokens[3]).toEqual value: 'test', scopes: ['source.ruby', 'string.regexp.interpolated.ruby']
    expect(tokens[4]).toEqual value: '/', scopes: ['source.ruby', 'string.regexp.interpolated.ruby', 'punctuation.section.regexp.ruby']
    expect(tokens[5]).toEqual value: ')', scopes: ['source.ruby', 'punctuation.section.function.ruby']

    {tokens} = grammar.tokenizeLine('/test/.match("test")')

    expect(tokens[0]).toEqual value: '/', scopes: ['source.ruby', 'string.regexp.interpolated.ruby', 'punctuation.section.regexp.ruby']
    expect(tokens[1]).toEqual value: 'test', scopes: ['source.ruby', 'string.regexp.interpolated.ruby']
    expect(tokens[2]).toEqual value: '/', scopes: ['source.ruby', 'string.regexp.interpolated.ruby', 'punctuation.section.regexp.ruby']
    expect(tokens[3]).toEqual value: '.', scopes: ['source.ruby', 'punctuation.separator.method.ruby']

    {tokens} = grammar.tokenizeLine('foo(4 / 2).split(/c/)')

    expect(tokens[0]).toEqual value: 'foo', scopes: ['source.ruby']
    expect(tokens[1]).toEqual value: '(', scopes: ['source.ruby', 'punctuation.section.function.ruby']
    expect(tokens[2]).toEqual value: '4', scopes: ['source.ruby', 'constant.numeric.ruby']
    expect(tokens[3]).toEqual value: ' ', scopes: ['source.ruby']
    expect(tokens[4]).toEqual value: '/', scopes: ['source.ruby', 'keyword.operator.arithmetic.ruby']
    expect(tokens[5]).toEqual value: ' ', scopes: ['source.ruby']
    expect(tokens[6]).toEqual value: '2', scopes: ['source.ruby', 'constant.numeric.ruby']
    expect(tokens[7]).toEqual value: ')', scopes: ['source.ruby', 'punctuation.section.function.ruby']
    expect(tokens[8]).toEqual value: '.', scopes: ['source.ruby', 'punctuation.separator.method.ruby']
    expect(tokens[9]).toEqual value: 'split', scopes: ['source.ruby']
    expect(tokens[10]).toEqual value: '(', scopes: ['source.ruby', 'punctuation.section.function.ruby']
    expect(tokens[11]).toEqual value: '/', scopes: ['source.ruby', 'string.regexp.interpolated.ruby', 'punctuation.section.regexp.ruby']
    expect(tokens[12]).toEqual value: 'c', scopes: ['source.ruby', 'string.regexp.interpolated.ruby']
    expect(tokens[13]).toEqual value: '/', scopes: ['source.ruby', 'string.regexp.interpolated.ruby', 'punctuation.section.regexp.ruby']
    expect(tokens[14]).toEqual value: ')', scopes: ['source.ruby', 'punctuation.section.function.ruby']

    {tokens} = grammar.tokenizeLine('[/test/,3]')

    expect(tokens[0]).toEqual value: '[', scopes: ['source.ruby', 'punctuation.section.array.begin.ruby']
    expect(tokens[1]).toEqual value: '/', scopes: ['source.ruby', 'string.regexp.interpolated.ruby', 'punctuation.section.regexp.ruby']
    expect(tokens[2]).toEqual value: 'test', scopes: ['source.ruby', 'string.regexp.interpolated.ruby']
    expect(tokens[3]).toEqual value: '/', scopes: ['source.ruby', 'string.regexp.interpolated.ruby', 'punctuation.section.regexp.ruby']
    expect(tokens[4]).toEqual value: ',', scopes: ['source.ruby', 'punctuation.separator.object.ruby']

    {tokens} = grammar.tokenizeLine('[/test/]')

    expect(tokens[0]).toEqual value: '[', scopes: ['source.ruby', 'punctuation.section.array.begin.ruby']
    expect(tokens[1]).toEqual value: '/', scopes: ['source.ruby', 'string.regexp.interpolated.ruby', 'punctuation.section.regexp.ruby']
    expect(tokens[2]).toEqual value: 'test', scopes: ['source.ruby', 'string.regexp.interpolated.ruby']
    expect(tokens[3]).toEqual value: '/', scopes: ['source.ruby', 'string.regexp.interpolated.ruby', 'punctuation.section.regexp.ruby']

    {tokens} = grammar.tokenizeLine('/test/ && 4')

    expect(tokens[0]).toEqual value: '/', scopes: ['source.ruby', 'string.regexp.interpolated.ruby', 'punctuation.section.regexp.ruby']
    expect(tokens[1]).toEqual value: 'test', scopes: ['source.ruby', 'string.regexp.interpolated.ruby']
    expect(tokens[2]).toEqual value: '/', scopes: ['source.ruby', 'string.regexp.interpolated.ruby', 'punctuation.section.regexp.ruby']
    expect(tokens[3]).toEqual value: ' ', scopes: ['source.ruby']

    {tokens} = grammar.tokenizeLine('/test/ || 4')

    expect(tokens[0]).toEqual value: '/', scopes: ['source.ruby', 'string.regexp.interpolated.ruby', 'punctuation.section.regexp.ruby']
    expect(tokens[1]).toEqual value: 'test', scopes: ['source.ruby', 'string.regexp.interpolated.ruby']
    expect(tokens[2]).toEqual value: '/', scopes: ['source.ruby', 'string.regexp.interpolated.ruby', 'punctuation.section.regexp.ruby']
    expect(tokens[3]).toEqual value: ' ', scopes: ['source.ruby']

    {tokens} = grammar.tokenizeLine('/test/ ? 4 : 3')

    expect(tokens[0]).toEqual value: '/', scopes: ['source.ruby', 'string.regexp.interpolated.ruby', 'punctuation.section.regexp.ruby']
    expect(tokens[1]).toEqual value: 'test', scopes: ['source.ruby', 'string.regexp.interpolated.ruby']
    expect(tokens[2]).toEqual value: '/', scopes: ['source.ruby', 'string.regexp.interpolated.ruby', 'punctuation.section.regexp.ruby']
    expect(tokens[3]).toEqual value: ' ', scopes: ['source.ruby']

    {tokens} = grammar.tokenizeLine('/test/ : foo')

    expect(tokens[0]).toEqual value: '/', scopes: ['source.ruby', 'string.regexp.interpolated.ruby', 'punctuation.section.regexp.ruby']
    expect(tokens[1]).toEqual value: 'test', scopes: ['source.ruby', 'string.regexp.interpolated.ruby']
    expect(tokens[2]).toEqual value: '/', scopes: ['source.ruby', 'string.regexp.interpolated.ruby', 'punctuation.section.regexp.ruby']
    expect(tokens[3]).toEqual value: ' ', scopes: ['source.ruby']

    {tokens} = grammar.tokenizeLine('{a: /test/}')

    expect(tokens[4]).toEqual value: '/', scopes: ['source.ruby', 'string.regexp.interpolated.ruby', 'punctuation.section.regexp.ruby']
    expect(tokens[5]).toEqual value: 'test', scopes: ['source.ruby', 'string.regexp.interpolated.ruby']
    expect(tokens[6]).toEqual value: '/', scopes: ['source.ruby', 'string.regexp.interpolated.ruby', 'punctuation.section.regexp.ruby']

    {tokens} = grammar.tokenizeLine('if "test" =~ /test/ then 4 end')

    expect(tokens[8]).toEqual value: '/', scopes: ['source.ruby', 'string.regexp.interpolated.ruby', 'punctuation.section.regexp.ruby']
    expect(tokens[9]).toEqual value: 'test', scopes: ['source.ruby', 'string.regexp.interpolated.ruby']
    expect(tokens[10]).toEqual value: '/', scopes: ['source.ruby', 'string.regexp.interpolated.ruby', 'punctuation.section.regexp.ruby']
    expect(tokens[11]).toEqual value: ' ', scopes: ['source.ruby']
    expect(tokens[12]).toEqual value: 'then', scopes: ['source.ruby', 'keyword.control.ruby']

    {tokens} = grammar.tokenizeLine('if "test" =~ /test/; 4 end')

    expect(tokens[8]).toEqual value: '/', scopes: ['source.ruby', 'string.regexp.interpolated.ruby', 'punctuation.section.regexp.ruby']
    expect(tokens[9]).toEqual value: 'test', scopes: ['source.ruby', 'string.regexp.interpolated.ruby']
    expect(tokens[10]).toEqual value: '/', scopes: ['source.ruby', 'string.regexp.interpolated.ruby', 'punctuation.section.regexp.ruby']
    expect(tokens[11]).toEqual value: ';', scopes: ['source.ruby', 'punctuation.separator.statement.ruby']

    {tokens} = grammar.tokenizeLine('/test/ =~ "test"')

    expect(tokens[0]).toEqual value: '/', scopes: ['source.ruby', 'string.regexp.interpolated.ruby', 'punctuation.section.regexp.ruby']
    expect(tokens[1]).toEqual value: 'test', scopes: ['source.ruby', 'string.regexp.interpolated.ruby']
    expect(tokens[2]).toEqual value: '/', scopes: ['source.ruby', 'string.regexp.interpolated.ruby', 'punctuation.section.regexp.ruby']
    expect(tokens[3]).toEqual value: ' ', scopes: ['source.ruby']
    expect(tokens[4]).toEqual value: '=~', scopes: ['source.ruby', 'keyword.operator.comparison.ruby']

    {tokens} = grammar.tokenizeLine('/test/ !~ "test"')

    expect(tokens[0]).toEqual value: '/', scopes: ['source.ruby', 'string.regexp.interpolated.ruby', 'punctuation.section.regexp.ruby']
    expect(tokens[1]).toEqual value: 'test', scopes: ['source.ruby', 'string.regexp.interpolated.ruby']
    expect(tokens[2]).toEqual value: '/', scopes: ['source.ruby', 'string.regexp.interpolated.ruby', 'punctuation.section.regexp.ruby']
    expect(tokens[3]).toEqual value: ' ', scopes: ['source.ruby']
    expect(tokens[4]).toEqual value: '!~', scopes: ['source.ruby', 'keyword.operator.comparison.ruby']

    {tokens} = grammar.tokenizeLine('/test/ != "test"')

    expect(tokens[0]).toEqual value: '/', scopes: ['source.ruby', 'string.regexp.interpolated.ruby', 'punctuation.section.regexp.ruby']
    expect(tokens[1]).toEqual value: 'test', scopes: ['source.ruby', 'string.regexp.interpolated.ruby']
    expect(tokens[2]).toEqual value: '/', scopes: ['source.ruby', 'string.regexp.interpolated.ruby', 'punctuation.section.regexp.ruby']
    expect(tokens[3]).toEqual value: ' ', scopes: ['source.ruby']
    expect(tokens[4]).toEqual value: '!=', scopes: ['source.ruby', 'keyword.operator.comparison.ruby']

    {tokens} = grammar.tokenizeLine('/test/ == /test/')

    expect(tokens[0]).toEqual value: '/', scopes: ['source.ruby', 'string.regexp.interpolated.ruby', 'punctuation.section.regexp.ruby']
    expect(tokens[1]).toEqual value: 'test', scopes: ['source.ruby', 'string.regexp.interpolated.ruby']
    expect(tokens[2]).toEqual value: '/', scopes: ['source.ruby', 'string.regexp.interpolated.ruby', 'punctuation.section.regexp.ruby']
    expect(tokens[3]).toEqual value: ' ', scopes: ['source.ruby']
    expect(tokens[4]).toEqual value: '==', scopes: ['source.ruby', 'keyword.operator.comparison.ruby']
    expect(tokens[5]).toEqual value: ' ', scopes: ['source.ruby']
    expect(tokens[6]).toEqual value: '/', scopes: ['source.ruby', 'string.regexp.interpolated.ruby', 'punctuation.section.regexp.ruby']
    expect(tokens[7]).toEqual value: 'test', scopes: ['source.ruby', 'string.regexp.interpolated.ruby']
    expect(tokens[8]).toEqual value: '/', scopes: ['source.ruby', 'string.regexp.interpolated.ruby', 'punctuation.section.regexp.ruby']

    {tokens} = grammar.tokenizeLine('/test/ === /test/')

    expect(tokens[0]).toEqual value: '/', scopes: ['source.ruby', 'string.regexp.interpolated.ruby', 'punctuation.section.regexp.ruby']
    expect(tokens[1]).toEqual value: 'test', scopes: ['source.ruby', 'string.regexp.interpolated.ruby']
    expect(tokens[2]).toEqual value: '/', scopes: ['source.ruby', 'string.regexp.interpolated.ruby', 'punctuation.section.regexp.ruby']
    expect(tokens[3]).toEqual value: ' ', scopes: ['source.ruby']
    expect(tokens[4]).toEqual value: '===', scopes: ['source.ruby', 'keyword.operator.comparison.ruby']
    expect(tokens[5]).toEqual value: ' ', scopes: ['source.ruby']
    expect(tokens[6]).toEqual value: '/', scopes: ['source.ruby', 'string.regexp.interpolated.ruby', 'punctuation.section.regexp.ruby']
    expect(tokens[7]).toEqual value: 'test', scopes: ['source.ruby', 'string.regexp.interpolated.ruby']
    expect(tokens[8]).toEqual value: '/', scopes: ['source.ruby', 'string.regexp.interpolated.ruby', 'punctuation.section.regexp.ruby']

    {tokens} = grammar.tokenizeLine('if false then /test/ else 4 end')

    expect(tokens[4]).toEqual value: 'then', scopes: ['source.ruby', 'keyword.control.ruby']
    expect(tokens[5]).toEqual value: ' ', scopes: ['source.ruby']
    expect(tokens[6]).toEqual value: '/', scopes: ['source.ruby', 'string.regexp.interpolated.ruby', 'punctuation.section.regexp.ruby']
    expect(tokens[7]).toEqual value: 'test', scopes: ['source.ruby', 'string.regexp.interpolated.ruby']
    expect(tokens[8]).toEqual value: '/', scopes: ['source.ruby', 'string.regexp.interpolated.ruby', 'punctuation.section.regexp.ruby']
    expect(tokens[9]).toEqual value: ' ', scopes: ['source.ruby']
    expect(tokens[10]).toEqual value: 'else', scopes: ['source.ruby', 'keyword.control.ruby']

    {tokens} = grammar.tokenizeLine('if false then 4 else /test/ end')

    expect(tokens[8]).toEqual value: 'else', scopes: ['source.ruby', 'keyword.control.ruby']
    expect(tokens[9]).toEqual value: ' ', scopes: ['source.ruby']
    expect(tokens[10]).toEqual value: '/', scopes: ['source.ruby', 'string.regexp.interpolated.ruby', 'punctuation.section.regexp.ruby']
    expect(tokens[11]).toEqual value: 'test', scopes: ['source.ruby', 'string.regexp.interpolated.ruby']
    expect(tokens[12]).toEqual value: '/', scopes: ['source.ruby', 'string.regexp.interpolated.ruby', 'punctuation.section.regexp.ruby']
    expect(tokens[13]).toEqual value: ' ', scopes: ['source.ruby']
    expect(tokens[14]).toEqual value: 'end', scopes: ['source.ruby', 'keyword.control.ruby']

    {tokens} = grammar.tokenizeLine('if true then /test/ elsif false then 4 end')

    expect(tokens[4]).toEqual value: 'then', scopes: ['source.ruby', 'keyword.control.ruby']
    expect(tokens[5]).toEqual value: ' ', scopes: ['source.ruby']
    expect(tokens[6]).toEqual value: '/', scopes: ['source.ruby', 'string.regexp.interpolated.ruby', 'punctuation.section.regexp.ruby']
    expect(tokens[7]).toEqual value: 'test', scopes: ['source.ruby', 'string.regexp.interpolated.ruby']
    expect(tokens[8]).toEqual value: '/', scopes: ['source.ruby', 'string.regexp.interpolated.ruby', 'punctuation.section.regexp.ruby']
    expect(tokens[9]).toEqual value: ' ', scopes: ['source.ruby']
    expect(tokens[10]).toEqual value: 'elsif', scopes: ['source.ruby', 'keyword.control.ruby']

    {tokens} = grammar.tokenizeLine('method /test/ do; end')

    expect(tokens[1]).toEqual value: '/', scopes: ['source.ruby', 'string.regexp.interpolated.ruby', 'punctuation.section.regexp.ruby']
    expect(tokens[2]).toEqual value: 'test', scopes: ['source.ruby', 'string.regexp.interpolated.ruby']
    expect(tokens[3]).toEqual value: '/', scopes: ['source.ruby', 'string.regexp.interpolated.ruby', 'punctuation.section.regexp.ruby']
    expect(tokens[4]).toEqual value: ' ', scopes: ['source.ruby']
    expect(tokens[5]).toEqual value: 'do', scopes: ['source.ruby', 'keyword.control.start-block.ruby']

    {tokens} = grammar.tokenizeLine('/test/ if true')

    expect(tokens[0]).toEqual value: '/', scopes: ['source.ruby', 'string.regexp.interpolated.ruby', 'punctuation.section.regexp.ruby']
    expect(tokens[1]).toEqual value: 'test', scopes: ['source.ruby', 'string.regexp.interpolated.ruby']
    expect(tokens[2]).toEqual value: '/', scopes: ['source.ruby', 'string.regexp.interpolated.ruby', 'punctuation.section.regexp.ruby']
    expect(tokens[3]).toEqual value: ' ', scopes: ['source.ruby']
    expect(tokens[4]).toEqual value: 'if', scopes: ['source.ruby', 'keyword.control.ruby']

    {tokens} = grammar.tokenizeLine('/test/ unless true')

    expect(tokens[0]).toEqual value: '/', scopes: ['source.ruby', 'string.regexp.interpolated.ruby', 'punctuation.section.regexp.ruby']
    expect(tokens[1]).toEqual value: 'test', scopes: ['source.ruby', 'string.regexp.interpolated.ruby']
    expect(tokens[2]).toEqual value: '/', scopes: ['source.ruby', 'string.regexp.interpolated.ruby', 'punctuation.section.regexp.ruby']
    expect(tokens[3]).toEqual value: ' ', scopes: ['source.ruby']
    expect(tokens[4]).toEqual value: 'unless', scopes: ['source.ruby', 'keyword.control.ruby']

    {tokens} = grammar.tokenizeLine('/test/ while true')

    expect(tokens[0]).toEqual value: '/', scopes: ['source.ruby', 'string.regexp.interpolated.ruby', 'punctuation.section.regexp.ruby']
    expect(tokens[1]).toEqual value: 'test', scopes: ['source.ruby', 'string.regexp.interpolated.ruby']
    expect(tokens[2]).toEqual value: '/', scopes: ['source.ruby', 'string.regexp.interpolated.ruby', 'punctuation.section.regexp.ruby']
    expect(tokens[3]).toEqual value: ' ', scopes: ['source.ruby']
    expect(tokens[4]).toEqual value: 'while', scopes: ['source.ruby', 'keyword.control.ruby']

    {tokens} = grammar.tokenizeLine('/test/ until true')

    expect(tokens[0]).toEqual value: '/', scopes: ['source.ruby', 'string.regexp.interpolated.ruby', 'punctuation.section.regexp.ruby']
    expect(tokens[1]).toEqual value: 'test', scopes: ['source.ruby', 'string.regexp.interpolated.ruby']
    expect(tokens[2]).toEqual value: '/', scopes: ['source.ruby', 'string.regexp.interpolated.ruby', 'punctuation.section.regexp.ruby']
    expect(tokens[3]).toEqual value: ' ', scopes: ['source.ruby']
    expect(tokens[4]).toEqual value: 'until', scopes: ['source.ruby', 'keyword.control.ruby']

    {tokens} = grammar.tokenizeLine('/test/ or return')

    expect(tokens[0]).toEqual value: '/', scopes: ['source.ruby', 'string.regexp.interpolated.ruby', 'punctuation.section.regexp.ruby']
    expect(tokens[1]).toEqual value: 'test', scopes: ['source.ruby', 'string.regexp.interpolated.ruby']
    expect(tokens[2]).toEqual value: '/', scopes: ['source.ruby', 'string.regexp.interpolated.ruby', 'punctuation.section.regexp.ruby']
    expect(tokens[3]).toEqual value: ' ', scopes: ['source.ruby']
    expect(tokens[4]).toEqual value: 'or', scopes: ['source.ruby', 'keyword.operator.logical.ruby']
    expect(tokens[5]).toEqual value: ' ', scopes: ['source.ruby']
    expect(tokens[6]).toEqual value: 'return', scopes: ['source.ruby', 'keyword.control.pseudo-method.ruby']

    {tokens} = grammar.tokenizeLine('/test/ and return')

    expect(tokens[0]).toEqual value: '/', scopes: ['source.ruby', 'string.regexp.interpolated.ruby', 'punctuation.section.regexp.ruby']
    expect(tokens[1]).toEqual value: 'test', scopes: ['source.ruby', 'string.regexp.interpolated.ruby']
    expect(tokens[2]).toEqual value: '/', scopes: ['source.ruby', 'string.regexp.interpolated.ruby', 'punctuation.section.regexp.ruby']
    expect(tokens[3]).toEqual value: ' ', scopes: ['source.ruby']
    expect(tokens[4]).toEqual value: 'and', scopes: ['source.ruby', 'keyword.operator.logical.ruby']
    expect(tokens[5]).toEqual value: ' ', scopes: ['source.ruby']
    expect(tokens[6]).toEqual value: 'return', scopes: ['source.ruby', 'keyword.control.pseudo-method.ruby']

    {tokens} = grammar.tokenizeLine('{/test/ => 1}')

    expect(tokens[1]).toEqual value: '/', scopes: ['source.ruby', 'string.regexp.interpolated.ruby', 'punctuation.section.regexp.ruby']
    expect(tokens[2]).toEqual value: 'test', scopes: ['source.ruby', 'string.regexp.interpolated.ruby']
    expect(tokens[3]).toEqual value: '/', scopes: ['source.ruby', 'string.regexp.interpolated.ruby', 'punctuation.section.regexp.ruby']
    expect(tokens[4]).toEqual value: ' ', scopes: ['source.ruby']
    expect(tokens[5]).toEqual value: '=>', scopes: ['source.ruby', 'punctuation.separator.key-value']
    expect(tokens[6]).toEqual value: ' ', scopes: ['source.ruby']
    expect(tokens[7]).toEqual value: '1', scopes: ['source.ruby', 'constant.numeric.ruby']

  it "tokenizes the / arithmetic operator", ->
    {tokens} = grammar.tokenizeLine('call/me/maybe')
    expect(tokens[0]).toEqual value: 'call', scopes: ['source.ruby']
    expect(tokens[1]).toEqual value: '/', scopes: ['source.ruby', 'keyword.operator.arithmetic.ruby']
    expect(tokens[2]).toEqual value: 'me', scopes: ['source.ruby']
    expect(tokens[3]).toEqual value: '/', scopes: ['source.ruby', 'keyword.operator.arithmetic.ruby']
    expect(tokens[4]).toEqual value: 'maybe', scopes: ['source.ruby']

    {tokens} = grammar.tokenizeLine('(1+2)/3/4')
    expect(tokens[0]).toEqual value: '(', scopes: ['source.ruby', 'punctuation.section.function.ruby']
    expect(tokens[1]).toEqual value: '1', scopes: ['source.ruby', 'constant.numeric.ruby']
    expect(tokens[2]).toEqual value: '+', scopes: ['source.ruby', 'keyword.operator.arithmetic.ruby']
    expect(tokens[3]).toEqual value: '2', scopes: ['source.ruby', 'constant.numeric.ruby']
    expect(tokens[4]).toEqual value: ')', scopes: ['source.ruby', 'punctuation.section.function.ruby']
    expect(tokens[5]).toEqual value: '/', scopes: ['source.ruby', 'keyword.operator.arithmetic.ruby']
    expect(tokens[6]).toEqual value: '3', scopes: ['source.ruby', 'constant.numeric.ruby']
    expect(tokens[7]).toEqual value: '/', scopes: ['source.ruby', 'keyword.operator.arithmetic.ruby']
    expect(tokens[8]).toEqual value: '4', scopes: ['source.ruby', 'constant.numeric.ruby']

    {tokens} = grammar.tokenizeLine('1 / 2 / 3')
    expect(tokens[0]).toEqual value: '1', scopes: ['source.ruby', 'constant.numeric.ruby']
    expect(tokens[1]).toEqual value: ' ', scopes: ['source.ruby']
    expect(tokens[2]).toEqual value: '/', scopes: ['source.ruby', 'keyword.operator.arithmetic.ruby']
    expect(tokens[3]).toEqual value: ' ', scopes: ['source.ruby']
    expect(tokens[4]).toEqual value: '2', scopes: ['source.ruby', 'constant.numeric.ruby']
    expect(tokens[5]).toEqual value: ' ', scopes: ['source.ruby']
    expect(tokens[6]).toEqual value: '/', scopes: ['source.ruby', 'keyword.operator.arithmetic.ruby']
    expect(tokens[7]).toEqual value: ' ', scopes: ['source.ruby']
    expect(tokens[8]).toEqual value: '3', scopes: ['source.ruby', 'constant.numeric.ruby']

    {tokens} = grammar.tokenizeLine('1/ 2 / 3')
    expect(tokens[0]).toEqual value: '1', scopes: ['source.ruby', 'constant.numeric.ruby']
    expect(tokens[1]).toEqual value: '/', scopes: ['source.ruby', 'keyword.operator.arithmetic.ruby']
    expect(tokens[2]).toEqual value: ' ', scopes: ['source.ruby']
    expect(tokens[3]).toEqual value: '2', scopes: ['source.ruby', 'constant.numeric.ruby']
    expect(tokens[4]).toEqual value: ' ', scopes: ['source.ruby']
    expect(tokens[5]).toEqual value: '/', scopes: ['source.ruby', 'keyword.operator.arithmetic.ruby']
    expect(tokens[6]).toEqual value: ' ', scopes: ['source.ruby']
    expect(tokens[7]).toEqual value: '3', scopes: ['source.ruby', 'constant.numeric.ruby']

    {tokens} = grammar.tokenizeLine('1 / 2/ 3')
    expect(tokens[0]).toEqual value: '1', scopes: ['source.ruby', 'constant.numeric.ruby']
    expect(tokens[1]).toEqual value: ' ', scopes: ['source.ruby']
    expect(tokens[2]).toEqual value: '/', scopes: ['source.ruby', 'keyword.operator.arithmetic.ruby']
    expect(tokens[3]).toEqual value: ' ', scopes: ['source.ruby']
    expect(tokens[4]).toEqual value: '2', scopes: ['source.ruby', 'constant.numeric.ruby']
    expect(tokens[5]).toEqual value: '/', scopes: ['source.ruby', 'keyword.operator.arithmetic.ruby']
    expect(tokens[6]).toEqual value: ' ', scopes: ['source.ruby']
    expect(tokens[7]).toEqual value: '3', scopes: ['source.ruby', 'constant.numeric.ruby']

    {tokens} = grammar.tokenizeLine('x / 2; x /= 2')
    expect(tokens[1]).toEqual value: '/', scopes: ['source.ruby', 'keyword.operator.arithmetic.ruby']
    expect(tokens[2]).toEqual value: ' ', scopes: ['source.ruby']
    expect(tokens[3]).toEqual value: '2', scopes: ['source.ruby', 'constant.numeric.ruby']
    expect(tokens[4]).toEqual value: ';', scopes: ['source.ruby', 'punctuation.separator.statement.ruby']
    expect(tokens[6]).toEqual value: '/=', scopes: ['source.ruby', 'keyword.operator.assignment.augmented.ruby']
    expect(tokens[7]).toEqual value: ' ', scopes: ['source.ruby']
    expect(tokens[8]).toEqual value: '2', scopes: ['source.ruby', 'constant.numeric.ruby']

  it "tokenizes 'not' when used as method name", ->
    {tokens} = grammar.tokenizeLine('foo.not(bar)')
    expect(tokens[2]).toEqual value: 'not', scopes: ['source.ruby']

    {tokens} = grammar.tokenizeLine('not?(Array)')
    expect(tokens[0]).toEqual value: 'not?', scopes: ['source.ruby']

  it "tokenizes 'not' as logical operator", ->
    {tokens} = grammar.tokenizeLine('not true')
    expect(tokens[0]).toEqual value: 'not', scopes: ['source.ruby', 'keyword.operator.logical.ruby']

  it "tokenizes ! when used in method name", ->
    {tokens} = grammar.tokenizeLine('sort!')
    expect(tokens[0]).toEqual value: 'sort!', scopes: ['source.ruby']

  it "tokenizes ! as logical operator", ->
    {tokens} = grammar.tokenizeLine('!foo')
    expect(tokens[0]).toEqual value: '!', scopes: ['source.ruby', 'keyword.operator.logical.ruby']

  it "tokenizes != as comparison operator", ->
    {tokens} = grammar.tokenizeLine('foo != bar')
    expect(tokens[1]).toEqual value: '!=', scopes: ['source.ruby', 'keyword.operator.comparison.ruby']

  it "tokenizes yard documentation comments", ->
    {tokens} = grammar.tokenizeLine('# @private')
    expect(tokens[0]).toEqual value: '#', scopes: ['source.ruby', 'comment.line.number-sign.ruby', 'punctuation.definition.comment.ruby']
    expect(tokens[1]).toEqual value: ' ', scopes: ['source.ruby', 'comment.line.number-sign.ruby']
    expect(tokens[2]).toEqual value: '@', scopes: ['source.ruby', 'comment.line.number-sign.ruby', 'comment.line.keyword.punctuation.yard.ruby']
    expect(tokens[3]).toEqual value: 'private', scopes: ['source.ruby', 'comment.line.number-sign.ruby', 'comment.line.keyword.yard.ruby']

    {tokens} = grammar.tokenizeLine('# @deprecated Because I said so')
    expect(tokens[0]).toEqual value: '#', scopes: ['source.ruby', 'comment.line.number-sign.ruby', 'punctuation.definition.comment.ruby']
    expect(tokens[1]).toEqual value: ' ', scopes: ['source.ruby', 'comment.line.number-sign.ruby']
    expect(tokens[2]).toEqual value: '@', scopes: ['source.ruby', 'comment.line.number-sign.ruby', 'comment.line.keyword.punctuation.yard.ruby']
    expect(tokens[3]).toEqual value: 'deprecated', scopes: ['source.ruby', 'comment.line.number-sign.ruby', 'comment.line.keyword.yard.ruby']
    expect(tokens[4]).toEqual value: ' Because I said so', scopes: ['source.ruby', 'comment.line.number-sign.ruby', 'comment.line.string.yard.ruby']

    {tokens} = grammar.tokenizeLine('# @raise [Bar] Baz')
    expect(tokens[0]).toEqual value: '#', scopes: ['source.ruby', 'comment.line.number-sign.ruby', 'punctuation.definition.comment.ruby']
    expect(tokens[1]).toEqual value: ' ', scopes: ['source.ruby', 'comment.line.number-sign.ruby']
    expect(tokens[2]).toEqual value: '@', scopes: ['source.ruby', 'comment.line.number-sign.ruby', 'comment.line.keyword.punctuation.yard.ruby']
    expect(tokens[3]).toEqual value: 'raise', scopes: ['source.ruby', 'comment.line.number-sign.ruby', 'comment.line.keyword.yard.ruby']
    expect(tokens[4]).toEqual value: ' ', scopes: ['source.ruby', 'comment.line.number-sign.ruby', 'comment.line.yard.ruby']
    expect(tokens[5]).toEqual value: '[', scopes: ['source.ruby', 'comment.line.number-sign.ruby', 'comment.line.yard.ruby', 'comment.line.type.yard.ruby', 'comment.line.punctuation.yard.ruby']
    expect(tokens[6]).toEqual value: 'Bar', scopes: ['source.ruby', 'comment.line.number-sign.ruby', 'comment.line.yard.ruby', 'comment.line.type.yard.ruby']
    expect(tokens[7]).toEqual value: ']', scopes: ['source.ruby', 'comment.line.number-sign.ruby', 'comment.line.yard.ruby', 'comment.line.type.yard.ruby', 'comment.line.punctuation.yard.ruby']
    expect(tokens[8]).toEqual value: ' Baz', scopes: ['source.ruby', 'comment.line.number-sign.ruby', 'comment.line.string.yard.ruby']

    {tokens} = grammar.tokenizeLine('# @param foo [Bar] Baz')
    expect(tokens[0]).toEqual value: '#', scopes: ['source.ruby', 'comment.line.number-sign.ruby', 'punctuation.definition.comment.ruby']
    expect(tokens[1]).toEqual value: ' ', scopes: ['source.ruby', 'comment.line.number-sign.ruby']
    expect(tokens[2]).toEqual value: '@', scopes: ['source.ruby', 'comment.line.number-sign.ruby', 'comment.line.keyword.punctuation.yard.ruby']
    expect(tokens[3]).toEqual value: 'param', scopes: ['source.ruby', 'comment.line.number-sign.ruby', 'comment.line.keyword.yard.ruby']
    expect(tokens[4]).toEqual value: ' ', scopes: ['source.ruby', 'comment.line.number-sign.ruby', 'comment.line.yard.ruby']
    expect(tokens[5]).toEqual value: 'foo', scopes: ['source.ruby', 'comment.line.number-sign.ruby', 'comment.line.yard.ruby', 'comment.line.parameter.yard.ruby']
    expect(tokens[6]).toEqual value: ' ', scopes: ['source.ruby', 'comment.line.number-sign.ruby', 'comment.line.yard.ruby']
    expect(tokens[7]).toEqual value: '[', scopes: ['source.ruby', 'comment.line.number-sign.ruby', 'comment.line.yard.ruby', 'comment.line.type.yard.ruby', 'comment.line.punctuation.yard.ruby']
    expect(tokens[8]).toEqual value: 'Bar', scopes: ['source.ruby', 'comment.line.number-sign.ruby', 'comment.line.yard.ruby', 'comment.line.type.yard.ruby']
    expect(tokens[9]).toEqual value: ']', scopes: ['source.ruby', 'comment.line.number-sign.ruby', 'comment.line.yard.ruby', 'comment.line.type.yard.ruby', 'comment.line.punctuation.yard.ruby']
    expect(tokens[10]).toEqual value: ' Baz', scopes: ['source.ruby', 'comment.line.number-sign.ruby', 'comment.line.string.yard.ruby']

    {tokens} = grammar.tokenizeLine('# @param [Bar] Baz')
    expect(tokens[0]).toEqual value: '#', scopes: ['source.ruby', 'comment.line.number-sign.ruby', 'punctuation.definition.comment.ruby']
    expect(tokens[1]).toEqual value: ' ', scopes: ['source.ruby', 'comment.line.number-sign.ruby']
    expect(tokens[2]).toEqual value: '@', scopes: ['source.ruby', 'comment.line.number-sign.ruby', 'comment.line.keyword.punctuation.yard.ruby']
    expect(tokens[3]).toEqual value: 'param', scopes: ['source.ruby', 'comment.line.number-sign.ruby', 'comment.line.keyword.yard.ruby']
    expect(tokens[4]).toEqual value: ' ', scopes: ['source.ruby', 'comment.line.number-sign.ruby', 'comment.line.yard.ruby']
    expect(tokens[5]).toEqual value: '[', scopes: ['source.ruby', 'comment.line.number-sign.ruby', 'comment.line.yard.ruby', 'comment.line.type.yard.ruby', 'comment.line.punctuation.yard.ruby']
    expect(tokens[6]).toEqual value: 'Bar', scopes: ['source.ruby', 'comment.line.number-sign.ruby', 'comment.line.yard.ruby', 'comment.line.type.yard.ruby']
    expect(tokens[7]).toEqual value: ']', scopes: ['source.ruby', 'comment.line.number-sign.ruby', 'comment.line.yard.ruby', 'comment.line.type.yard.ruby', 'comment.line.punctuation.yard.ruby']
    expect(tokens[8]).toEqual value: ' Baz', scopes: ['source.ruby', 'comment.line.number-sign.ruby', 'comment.line.string.yard.ruby']

    {tokens} = grammar.tokenizeLine('# @return [Array#[](0), Array] comment')
    expect(tokens[0]).toEqual value: '#', scopes: ['source.ruby', 'comment.line.number-sign.ruby', 'punctuation.definition.comment.ruby']
    expect(tokens[1]).toEqual value: ' ', scopes: ['source.ruby', 'comment.line.number-sign.ruby']
    expect(tokens[2]).toEqual value: '@', scopes: ['source.ruby', 'comment.line.number-sign.ruby', 'comment.line.keyword.punctuation.yard.ruby']
    expect(tokens[3]).toEqual value: 'return', scopes: ['source.ruby', 'comment.line.number-sign.ruby', 'comment.line.keyword.yard.ruby']
    expect(tokens[4]).toEqual value: ' ', scopes: ['source.ruby', 'comment.line.number-sign.ruby', 'comment.line.yard.ruby']
    expect(tokens[5]).toEqual value: '[', scopes: ['source.ruby', 'comment.line.number-sign.ruby', 'comment.line.yard.ruby', 'comment.line.type.yard.ruby', 'comment.line.punctuation.yard.ruby']
    expect(tokens[6]).toEqual value: 'Array#[](0), Array', scopes: ['source.ruby', 'comment.line.number-sign.ruby', 'comment.line.yard.ruby', 'comment.line.type.yard.ruby']
    expect(tokens[7]).toEqual value: ']', scopes: ['source.ruby', 'comment.line.number-sign.ruby', 'comment.line.yard.ruby', 'comment.line.type.yard.ruby', 'comment.line.punctuation.yard.ruby']
    expect(tokens[8]).toEqual value: ' comment', scopes: ['source.ruby', 'comment.line.number-sign.ruby', 'comment.line.string.yard.ruby']

    {tokens} = grammar.tokenizeLine('# @param [Array#[](0), Array] comment')
    expect(tokens[0]).toEqual value: '#', scopes: ['source.ruby', 'comment.line.number-sign.ruby', 'punctuation.definition.comment.ruby']
    expect(tokens[1]).toEqual value: ' ', scopes: ['source.ruby', 'comment.line.number-sign.ruby']
    expect(tokens[2]).toEqual value: '@', scopes: ['source.ruby', 'comment.line.number-sign.ruby', 'comment.line.keyword.punctuation.yard.ruby']
    expect(tokens[3]).toEqual value: 'param', scopes: ['source.ruby', 'comment.line.number-sign.ruby', 'comment.line.keyword.yard.ruby']
    expect(tokens[4]).toEqual value: ' ', scopes: ['source.ruby', 'comment.line.number-sign.ruby', 'comment.line.yard.ruby']
    expect(tokens[5]).toEqual value: '[', scopes: ['source.ruby', 'comment.line.number-sign.ruby', 'comment.line.yard.ruby', 'comment.line.type.yard.ruby', 'comment.line.punctuation.yard.ruby']
    expect(tokens[6]).toEqual value: 'Array#[](0), Array', scopes: ['source.ruby', 'comment.line.number-sign.ruby', 'comment.line.yard.ruby', 'comment.line.type.yard.ruby']
    expect(tokens[7]).toEqual value: ']', scopes: ['source.ruby', 'comment.line.number-sign.ruby', 'comment.line.yard.ruby', 'comment.line.type.yard.ruby', 'comment.line.punctuation.yard.ruby']
    expect(tokens[8]).toEqual value: ' comment', scopes: ['source.ruby', 'comment.line.number-sign.ruby', 'comment.line.string.yard.ruby']

    {tokens} = grammar.tokenizeLine('# @!attribute [r] foo comment')
    expect(tokens[0]).toEqual value: '#', scopes: ['source.ruby', 'comment.line.number-sign.ruby', 'punctuation.definition.comment.ruby']
    expect(tokens[1]).toEqual value: ' ', scopes: ['source.ruby', 'comment.line.number-sign.ruby']
    expect(tokens[2]).toEqual value: '@!', scopes: ['source.ruby', 'comment.line.number-sign.ruby', 'comment.line.keyword.punctuation.yard.ruby']
    expect(tokens[3]).toEqual value: 'attribute', scopes: ['source.ruby', 'comment.line.number-sign.ruby', 'comment.line.keyword.yard.ruby']
    expect(tokens[4]).toEqual value: ' ', scopes: ['source.ruby', 'comment.line.number-sign.ruby', 'comment.line.yard.ruby']
    expect(tokens[5]).toEqual value: '[', scopes: ['source.ruby', 'comment.line.number-sign.ruby', 'comment.line.yard.ruby', 'comment.line.type.yard.ruby', 'comment.line.punctuation.yard.ruby']
    expect(tokens[6]).toEqual value: 'r', scopes: ['source.ruby', 'comment.line.number-sign.ruby', 'comment.line.yard.ruby', 'comment.line.type.yard.ruby']
    expect(tokens[7]).toEqual value: ']', scopes: ['source.ruby', 'comment.line.number-sign.ruby', 'comment.line.yard.ruby', 'comment.line.type.yard.ruby', 'comment.line.punctuation.yard.ruby']
    expect(tokens[8]).toEqual value: ' foo comment', scopes: ['source.ruby', 'comment.line.number-sign.ruby', 'comment.line.string.yard.ruby']

  it "tokenizes a method with *args properly", ->
    {tokens} = grammar.tokenizeLine('def method(*args)')
    expect(tokens[0]).toEqual value: 'def', scopes: ['source.ruby', 'meta.function.method.with-arguments.ruby', 'keyword.control.def.ruby']
    expect(tokens[2]).toEqual value: 'method', scopes: ['source.ruby', 'meta.function.method.with-arguments.ruby', 'entity.name.function.ruby']
    expect(tokens[3]).toEqual value: '(', scopes: ['source.ruby', 'meta.function.method.with-arguments.ruby', 'punctuation.definition.parameters.ruby']
    expect(tokens[4]).toEqual value: '*', scopes: ['source.ruby', 'meta.function.method.with-arguments.ruby', 'storage.type.variable.ruby']
    expect(tokens[5]).toEqual value: 'args', scopes: ['source.ruby', 'meta.function.method.with-arguments.ruby', 'variable.parameter.function.ruby']
    expect(tokens[6]).toEqual value: ')', scopes: ['source.ruby', 'meta.function.method.with-arguments.ruby', 'punctuation.definition.parameters.ruby']

    {tokens} = grammar.tokenizeLine('def method(args)')
    expect(tokens[0]).toEqual value: 'def', scopes: ['source.ruby', 'meta.function.method.with-arguments.ruby', 'keyword.control.def.ruby']
    expect(tokens[2]).toEqual value: 'method', scopes: ['source.ruby', 'meta.function.method.with-arguments.ruby', 'entity.name.function.ruby']
    expect(tokens[3]).toEqual value: '(', scopes: ['source.ruby', 'meta.function.method.with-arguments.ruby', 'punctuation.definition.parameters.ruby']
    expect(tokens[4]).toEqual value: 'args', scopes: ['source.ruby', 'meta.function.method.with-arguments.ruby', 'variable.parameter.function.ruby']
    expect(tokens[5]).toEqual value: ')', scopes: ['source.ruby', 'meta.function.method.with-arguments.ruby', 'punctuation.definition.parameters.ruby']

    {tokens} = grammar.tokenizeLine('def method *args')
    expect(tokens[0]).toEqual value: 'def', scopes: ['source.ruby', 'meta.function.method.with-arguments.ruby', 'keyword.control.def.ruby']
    expect(tokens[2]).toEqual value: 'method', scopes: ['source.ruby', 'meta.function.method.with-arguments.ruby', 'entity.name.function.ruby']
    expect(tokens[3]).toEqual value: ' ', scopes: ['source.ruby', 'meta.function.method.with-arguments.ruby']
    expect(tokens[4]).toEqual value: '*', scopes: ['source.ruby', 'meta.function.method.with-arguments.ruby', 'storage.type.variable.ruby']
    expect(tokens[5]).toEqual value: 'args', scopes: ['source.ruby', 'meta.function.method.with-arguments.ruby', 'variable.parameter.function.ruby']

  it "tokenizes a method with (symbol: arg) properly", ->
    {tokens} = grammar.tokenizeLine('def method(red: 2)')
    expect(tokens[0]).toEqual value: 'def', scopes: ['source.ruby', 'meta.function.method.with-arguments.ruby', 'keyword.control.def.ruby']
    expect(tokens[2]).toEqual value: 'method', scopes: ['source.ruby', 'meta.function.method.with-arguments.ruby', 'entity.name.function.ruby']
    expect(tokens[3]).toEqual value: '(', scopes: ['source.ruby', 'meta.function.method.with-arguments.ruby', 'punctuation.definition.parameters.ruby']
    expect(tokens[4]).toEqual value: 'red', scopes: ['source.ruby', 'meta.function.method.with-arguments.ruby', 'constant.other.symbol.hashkey.parameter.function.ruby']
    expect(tokens[7]).toEqual value: '2', scopes: ['source.ruby', 'meta.function.method.with-arguments.ruby', 'constant.numeric.ruby']

  it "tokenizes a method with symbol: arg (no paren) properly", ->
    {tokens} = grammar.tokenizeLine('def method red: 2')
    expect(tokens[0]).toEqual value: 'def', scopes: ['source.ruby', 'meta.function.method.with-arguments.ruby', 'keyword.control.def.ruby']
    expect(tokens[2]).toEqual value: 'method', scopes: ['source.ruby', 'meta.function.method.with-arguments.ruby', 'entity.name.function.ruby']
    expect(tokens[4]).toEqual value: 'red', scopes: ['source.ruby', 'meta.function.method.with-arguments.ruby', 'constant.other.symbol.hashkey.parameter.function.ruby']
    expect(tokens[7]).toEqual value: '2', scopes: ['source.ruby', 'meta.function.method.with-arguments.ruby', 'constant.numeric.ruby']

  it "tokenizes a method with (symbol: arg(paren), symbol: arg2(paren)...) properly", ->
    {tokens} = grammar.tokenizeLine('def method(red: rand(2), green: rand(3), blue: rand(4))')
    expect(tokens[0]).toEqual value: 'def', scopes: ['source.ruby', 'meta.function.method.with-arguments.ruby', 'keyword.control.def.ruby']
    expect(tokens[2]).toEqual value: 'method', scopes: ['source.ruby', 'meta.function.method.with-arguments.ruby', 'entity.name.function.ruby']
    expect(tokens[3]).toEqual value: '(', scopes: ['source.ruby', 'meta.function.method.with-arguments.ruby', 'punctuation.definition.parameters.ruby']
    expect(tokens[4]).toEqual value: 'red', scopes: ['source.ruby', 'meta.function.method.with-arguments.ruby', 'constant.other.symbol.hashkey.parameter.function.ruby']
    expect(tokens[7]).toEqual value: 'rand', scopes: ['source.ruby', 'meta.function.method.with-arguments.ruby', 'support.function.kernel.ruby']
    expect(tokens[8]).toEqual value: '(', scopes: ['source.ruby', 'meta.function.method.with-arguments.ruby', 'punctuation.section.function.ruby']
    expect(tokens[9]).toEqual value: '2', scopes: ['source.ruby', 'meta.function.method.with-arguments.ruby', 'constant.numeric.ruby']
    expect(tokens[10]).toEqual value: ')', scopes: ['source.ruby', 'meta.function.method.with-arguments.ruby', 'punctuation.section.function.ruby']
    expect(tokens[12]).toEqual value: 'green', scopes: ['source.ruby', 'meta.function.method.with-arguments.ruby', 'constant.other.symbol.hashkey.parameter.function.ruby']
    expect(tokens[15]).toEqual value: 'rand', scopes: ['source.ruby', 'meta.function.method.with-arguments.ruby', 'support.function.kernel.ruby']
    expect(tokens[16]).toEqual value: '(', scopes: ['source.ruby', 'meta.function.method.with-arguments.ruby', 'punctuation.section.function.ruby']
    expect(tokens[17]).toEqual value: '3', scopes: ['source.ruby', 'meta.function.method.with-arguments.ruby', 'constant.numeric.ruby']
    expect(tokens[18]).toEqual value: ')', scopes: ['source.ruby', 'meta.function.method.with-arguments.ruby', 'punctuation.section.function.ruby']
    expect(tokens[20]).toEqual value: 'blue', scopes: ['source.ruby', 'meta.function.method.with-arguments.ruby', 'constant.other.symbol.hashkey.parameter.function.ruby']
    expect(tokens[23]).toEqual value: 'rand', scopes: ['source.ruby', 'meta.function.method.with-arguments.ruby', 'support.function.kernel.ruby']
    expect(tokens[24]).toEqual value: '(', scopes: ['source.ruby', 'meta.function.method.with-arguments.ruby', 'punctuation.section.function.ruby']
    expect(tokens[25]).toEqual value: '4', scopes: ['source.ruby', 'meta.function.method.with-arguments.ruby', 'constant.numeric.ruby']
    expect(tokens[26]).toEqual value: ')', scopes: ['source.ruby', 'meta.function.method.with-arguments.ruby', 'punctuation.section.function.ruby']

  it "tokenizes a method with symbol: arg(paren), symbol: arg2(paren)... (no outer parens) properly", ->
    {tokens} = grammar.tokenizeLine('def method red: rand(2), green: rand(3), blue: rand(4)')
    expect(tokens[0]).toEqual value: 'def', scopes: ['source.ruby', 'meta.function.method.with-arguments.ruby', 'keyword.control.def.ruby']
    expect(tokens[2]).toEqual value: 'method', scopes: ['source.ruby', 'meta.function.method.with-arguments.ruby', 'entity.name.function.ruby']
    expect(tokens[4]).toEqual value: 'red', scopes: ['source.ruby', 'meta.function.method.with-arguments.ruby', 'constant.other.symbol.hashkey.parameter.function.ruby']
    expect(tokens[7]).toEqual value: 'rand', scopes: ['source.ruby', 'meta.function.method.with-arguments.ruby', 'support.function.kernel.ruby']
    expect(tokens[8]).toEqual value: '(', scopes: ['source.ruby', 'meta.function.method.with-arguments.ruby', 'punctuation.section.function.ruby']
    expect(tokens[9]).toEqual value: '2', scopes: ['source.ruby', 'meta.function.method.with-arguments.ruby', 'constant.numeric.ruby']
    expect(tokens[10]).toEqual value: ')', scopes: ['source.ruby', 'meta.function.method.with-arguments.ruby', 'punctuation.section.function.ruby']
    expect(tokens[12]).toEqual value: 'green', scopes: ['source.ruby', 'meta.function.method.with-arguments.ruby', 'constant.other.symbol.hashkey.parameter.function.ruby']
    expect(tokens[15]).toEqual value: 'rand', scopes: ['source.ruby', 'meta.function.method.with-arguments.ruby', 'support.function.kernel.ruby']
    expect(tokens[16]).toEqual value: '(', scopes: ['source.ruby', 'meta.function.method.with-arguments.ruby', 'punctuation.section.function.ruby']
    expect(tokens[17]).toEqual value: '3', scopes: ['source.ruby', 'meta.function.method.with-arguments.ruby', 'constant.numeric.ruby']
    expect(tokens[18]).toEqual value: ')', scopes: ['source.ruby', 'meta.function.method.with-arguments.ruby', 'punctuation.section.function.ruby']
    expect(tokens[20]).toEqual value: 'blue', scopes: ['source.ruby', 'meta.function.method.with-arguments.ruby', 'constant.other.symbol.hashkey.parameter.function.ruby']
    expect(tokens[23]).toEqual value: 'rand', scopes: ['source.ruby', 'meta.function.method.with-arguments.ruby', 'support.function.kernel.ruby']
    expect(tokens[24]).toEqual value: '(', scopes: ['source.ruby', 'meta.function.method.with-arguments.ruby', 'punctuation.section.function.ruby']
    expect(tokens[25]).toEqual value: '4', scopes: ['source.ruby', 'meta.function.method.with-arguments.ruby', 'constant.numeric.ruby']
    expect(tokens[26]).toEqual value: ')', scopes: ['source.ruby', 'meta.function.method.with-arguments.ruby', 'punctuation.section.function.ruby']

  it "tokenizes a stabby lambda properly", ->
    {tokens} = grammar.tokenizeLine('method_name -> { puts "A message"} do')
    expect(tokens[1]).toEqual value: '->', scopes: ['source.ruby', 'support.function.kernel.ruby']

  it "tokenizes a simple do block properly", ->
    {tokens} = grammar.tokenizeLine('do |foo| ')
    expect(tokens[0]).toEqual value: 'do', scopes: ['source.ruby', 'keyword.control.start-block.ruby']
    expect(tokens[2]).toEqual value: '|', scopes: ['source.ruby', 'punctuation.separator.variable.ruby']
    expect(tokens[3]).toEqual value: 'foo', scopes: ['source.ruby', 'variable.other.block.ruby']
    expect(tokens[4]).toEqual value: '|', scopes: ['source.ruby', 'punctuation.separator.variable.ruby']

  it "tokenizes a complex do block properly", ->
    {tokens} = grammar.tokenizeLine('do |key = (a || b), hash = config, create: false|')
    expect(tokens[0]).toEqual value: 'do', scopes: ['source.ruby', 'keyword.control.start-block.ruby']
    expect(tokens[2]).toEqual value: '|', scopes: ['source.ruby', 'punctuation.separator.variable.ruby']
    expect(tokens[3]).toEqual value: 'key', scopes: ['source.ruby', 'variable.other.block.ruby']
    expect(tokens[5]).toEqual value: '=', scopes: ['source.ruby', 'keyword.operator.assignment.ruby']
    expect(tokens[7]).toEqual value: '(', scopes: ['source.ruby', 'punctuation.section.function.ruby']
    expect(tokens[8]).toEqual value: 'a', scopes: ['source.ruby', 'variable.other.block.ruby']
    expect(tokens[10]).toEqual value: '||', scopes: ['source.ruby', 'keyword.operator.logical.ruby']
    expect(tokens[12]).toEqual value: 'b', scopes: ['source.ruby', 'variable.other.block.ruby']
    expect(tokens[13]).toEqual value: ')', scopes: ['source.ruby', 'punctuation.section.function.ruby']
    expect(tokens[14]).toEqual value: ',', scopes: ['source.ruby', 'punctuation.separator.object.ruby']
    expect(tokens[16]).toEqual value: 'hash', scopes: ['source.ruby', 'variable.other.block.ruby']
    expect(tokens[18]).toEqual value: '=', scopes: ['source.ruby', 'keyword.operator.assignment.ruby']
    expect(tokens[20]).toEqual value: 'config', scopes: ['source.ruby', 'variable.other.block.ruby']
    expect(tokens[21]).toEqual value: ',', scopes: ['source.ruby', 'punctuation.separator.object.ruby']
    expect(tokens[23]).toEqual value: 'create', scopes: ['source.ruby', 'constant.other.symbol.hashkey.ruby']
    expect(tokens[24]).toEqual value: ':', scopes: ['source.ruby', 'constant.other.symbol.hashkey.ruby', 'punctuation.definition.constant.hashkey.ruby']
    expect(tokens[26]).toEqual value: 'false', scopes: ['source.ruby', 'constant.language.boolean.ruby']
    expect(tokens[27]).toEqual value: '|', scopes: ['source.ruby', 'punctuation.separator.variable.ruby']

  it "tokenizes <<- heredoc", ->
    lines = grammar.tokenizeLines('<<-EOS\nThis is text\nEOS')
    expect(lines[0][0]).toEqual value: '<<-EOS', scopes: ['source.ruby', 'string.unquoted.heredoc.ruby', 'punctuation.definition.string.begin.ruby']
    expect(lines[2][0]).toEqual value: 'EOS', scopes: ['source.ruby', 'string.unquoted.heredoc.ruby', 'punctuation.definition.string.end.ruby']

  it "tokenizes <<~ Ruby 2.3.0 squiggly heredoc", ->
    lines = grammar.tokenizeLines('<<~EOS\nThis is text\nEOS')
    expect(lines[0][0]).toEqual value: '<<~EOS', scopes: ['source.ruby', 'string.unquoted.heredoc.ruby', 'punctuation.definition.string.begin.ruby']
    expect(lines[2][0]).toEqual value: 'EOS', scopes: ['source.ruby', 'string.unquoted.heredoc.ruby', 'punctuation.definition.string.end.ruby']

  it "tokenizes Kernel support functions autoload? and exit!", ->
    lines = grammar.tokenizeLines('p autoload?(:test)\nexit!\nat_exit!')
    expect(lines[0][2]).toEqual value: 'autoload?', scopes: ['source.ruby', 'support.function.kernel.ruby']
    expect(lines[1][0]).toEqual value: 'exit!', scopes: ['source.ruby', 'support.function.kernel.ruby']
    expect(lines[2][0]).toEqual value: 'at_exit!', scopes: ['source.ruby']

  it "tokenizes iterator? the same way as block_given?", ->
    lines = grammar.tokenizeLines('p iterator?\np block_given?')
    expect(lines[0][2].value).toEqual 'iterator?'
    expect(lines[1][2].value).toEqual 'block_given?'
    expect(lines[0][2].scopes).toEqual lines[1][2].scopes
