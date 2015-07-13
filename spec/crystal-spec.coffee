describe "Crystal grammar", ->
  grammar = null

  beforeEach ->
    waitsForPromise ->
      atom.packages.activatePackage("language-crystal-actual")

    runs ->
      grammar = atom.grammars.grammarForScopeName("source.crystal")

  it "parses the grammar", ->
    expect(grammar).toBeTruthy()
    expect(grammar.scopeName).toBe "source.crystal"

  it "tokenizes self", ->
    {tokens} = grammar.tokenizeLine('self')
    expect(tokens[0]).toEqual value: 'self', scopes: ['source.crystal', 'variable.language.self.crystal']

  it "tokenizes symbols", ->
    {tokens} = grammar.tokenizeLine(':test')
    expect(tokens[0]).toEqual value: ':', scopes: ['source.crystal', 'constant.other.symbol.crystal', 'punctuation.definition.constant.crystal']
    expect(tokens[1]).toEqual value: 'test', scopes: ['source.crystal', 'constant.other.symbol.crystal']

    {tokens} = grammar.tokenizeLine(':$symbol')
    expect(tokens[0]).toEqual value: ':', scopes: ['source.crystal', 'constant.other.symbol.crystal', 'punctuation.definition.constant.crystal']
    expect(tokens[1]).toEqual value: '$symbol', scopes: ['source.crystal', 'constant.other.symbol.crystal']

  it "tokenizes %{} style strings", ->
    {tokens} = grammar.tokenizeLine('%{te{s}t}')

    expect(tokens[0]).toEqual value: '%{', scopes: ['source.crystal', 'string.quoted.other.interpolated.crystal', 'punctuation.definition.string.begin.crystal']
    expect(tokens[1]).toEqual value: 'te', scopes: ['source.crystal', 'string.quoted.other.interpolated.crystal']
    expect(tokens[2]).toEqual value: '{', scopes: ['source.crystal', 'string.quoted.other.interpolated.crystal', 'punctuation.section.scope.crystal']
    expect(tokens[3]).toEqual value: 's', scopes: ['source.crystal', 'string.quoted.other.interpolated.crystal']
    expect(tokens[4]).toEqual value: '}', scopes: ['source.crystal', 'string.quoted.other.interpolated.crystal', 'punctuation.section.scope.crystal']
    expect(tokens[5]).toEqual value: 't', scopes: ['source.crystal', 'string.quoted.other.interpolated.crystal']
    expect(tokens[6]).toEqual value: '}', scopes: ['source.crystal', 'string.quoted.other.interpolated.crystal', 'punctuation.definition.string.end.crystal']

  it "tokenizes %() style strings", ->
    {tokens} = grammar.tokenizeLine('%(te(s)t)')

    expect(tokens[0]).toEqual value: '%(', scopes: ['source.crystal', 'string.quoted.other.interpolated.crystal', 'punctuation.definition.string.begin.crystal']
    expect(tokens[1]).toEqual value: 'te', scopes: ['source.crystal', 'string.quoted.other.interpolated.crystal']
    expect(tokens[2]).toEqual value: '(', scopes: ['source.crystal', 'string.quoted.other.interpolated.crystal', 'punctuation.section.scope.crystal']
    expect(tokens[3]).toEqual value: 's', scopes: ['source.crystal', 'string.quoted.other.interpolated.crystal']
    expect(tokens[4]).toEqual value: ')', scopes: ['source.crystal', 'string.quoted.other.interpolated.crystal', 'punctuation.section.scope.crystal']
    expect(tokens[5]).toEqual value: 't', scopes: ['source.crystal', 'string.quoted.other.interpolated.crystal']
    expect(tokens[6]).toEqual value: ')', scopes: ['source.crystal', 'string.quoted.other.interpolated.crystal', 'punctuation.definition.string.end.crystal']

  it "tokenizes %[] style strings", ->
    {tokens} = grammar.tokenizeLine('%[te[s]t]')

    expect(tokens[0]).toEqual value: '%[', scopes: ['source.crystal', 'string.quoted.other.interpolated.crystal', 'punctuation.definition.string.begin.crystal']
    expect(tokens[1]).toEqual value: 'te', scopes: ['source.crystal', 'string.quoted.other.interpolated.crystal']
    expect(tokens[2]).toEqual value: '[', scopes: ['source.crystal', 'string.quoted.other.interpolated.crystal', 'punctuation.section.scope.crystal']
    expect(tokens[3]).toEqual value: 's', scopes: ['source.crystal', 'string.quoted.other.interpolated.crystal']
    expect(tokens[4]).toEqual value: ']', scopes: ['source.crystal', 'string.quoted.other.interpolated.crystal', 'punctuation.section.scope.crystal']
    expect(tokens[5]).toEqual value: 't', scopes: ['source.crystal', 'string.quoted.other.interpolated.crystal']
    expect(tokens[6]).toEqual value: ']', scopes: ['source.crystal', 'string.quoted.other.interpolated.crystal', 'punctuation.definition.string.end.crystal']

  it "tokenizes %<> style strings", ->
    {tokens} = grammar.tokenizeLine('%<te<s>t>')

    expect(tokens[0]).toEqual value: '%<', scopes: ['source.crystal', 'string.quoted.other.interpolated.crystal', 'punctuation.definition.string.begin.crystal']
    expect(tokens[1]).toEqual value: 'te', scopes: ['source.crystal', 'string.quoted.other.interpolated.crystal']
    expect(tokens[2]).toEqual value: '<', scopes: ['source.crystal', 'string.quoted.other.interpolated.crystal', 'punctuation.section.scope.crystal']
    expect(tokens[3]).toEqual value: 's', scopes: ['source.crystal', 'string.quoted.other.interpolated.crystal']
    expect(tokens[4]).toEqual value: '>', scopes: ['source.crystal', 'string.quoted.other.interpolated.crystal', 'punctuation.section.scope.crystal']
    expect(tokens[5]).toEqual value: 't', scopes: ['source.crystal', 'string.quoted.other.interpolated.crystal']
    expect(tokens[6]).toEqual value: '>', scopes: ['source.crystal', 'string.quoted.other.interpolated.crystal', 'punctuation.definition.string.end.crystal']

  it "tokenizes regular expressions", ->
    {tokens} = grammar.tokenizeLine('/test/')

    expect(tokens[0]).toEqual value: '/', scopes: ['source.crystal', 'string.regexp.interpolated.crystal', 'punctuation.section.regexp.crystal']
    expect(tokens[1]).toEqual value: 'test', scopes: ['source.crystal', 'string.regexp.interpolated.crystal']
    expect(tokens[2]).toEqual value: '/', scopes: ['source.crystal', 'string.regexp.interpolated.crystal', 'punctuation.section.regexp.crystal']

    {tokens} = grammar.tokenizeLine('/{w}/')

    expect(tokens[0]).toEqual value: '/', scopes: ['source.crystal', 'string.regexp.interpolated.crystal', 'punctuation.section.regexp.crystal']
    expect(tokens[1]).toEqual value: '{w}', scopes: ['source.crystal', 'string.regexp.interpolated.crystal']
    expect(tokens[2]).toEqual value: '/', scopes: ['source.crystal', 'string.regexp.interpolated.crystal', 'punctuation.section.regexp.crystal']

    {tokens} = grammar.tokenizeLine('a_method /test/')

    expect(tokens[0]).toEqual value: 'a_method ', scopes: ['source.crystal']
    expect(tokens[1]).toEqual value: '/', scopes: ['source.crystal', 'string.regexp.interpolated.crystal', 'punctuation.section.regexp.crystal']
    expect(tokens[2]).toEqual value: 'test', scopes: ['source.crystal', 'string.regexp.interpolated.crystal']
    expect(tokens[3]).toEqual value: '/', scopes: ['source.crystal', 'string.regexp.interpolated.crystal', 'punctuation.section.regexp.crystal']

    {tokens} = grammar.tokenizeLine('a_method(/test/)')

    expect(tokens[0]).toEqual value: 'a_method', scopes: ['source.crystal']
    expect(tokens[1]).toEqual value: '(', scopes: ['source.crystal', 'punctuation.section.function.crystal']
    expect(tokens[2]).toEqual value: '/', scopes: ['source.crystal', 'string.regexp.interpolated.crystal', 'punctuation.section.regexp.crystal']
    expect(tokens[3]).toEqual value: 'test', scopes: ['source.crystal', 'string.regexp.interpolated.crystal']
    expect(tokens[4]).toEqual value: '/', scopes: ['source.crystal', 'string.regexp.interpolated.crystal', 'punctuation.section.regexp.crystal']
    expect(tokens[5]).toEqual value: ')', scopes: ['source.crystal', 'punctuation.section.function.crystal']

    {tokens} = grammar.tokenizeLine('/test/.match("test")')

    expect(tokens[0]).toEqual value: '/', scopes: ['source.crystal', 'string.regexp.interpolated.crystal', 'punctuation.section.regexp.crystal']
    expect(tokens[1]).toEqual value: 'test', scopes: ['source.crystal', 'string.regexp.interpolated.crystal']
    expect(tokens[2]).toEqual value: '/', scopes: ['source.crystal', 'string.regexp.interpolated.crystal', 'punctuation.section.regexp.crystal']
    expect(tokens[3]).toEqual value: '.', scopes: ['source.crystal', 'punctuation.separator.method.crystal']

    {tokens} = grammar.tokenizeLine('foo(4 / 2).split(/c/)')

    expect(tokens[0]).toEqual value: 'foo', scopes: ['source.crystal']
    expect(tokens[1]).toEqual value: '(', scopes: ['source.crystal', 'punctuation.section.function.crystal']
    expect(tokens[2]).toEqual value: '4', scopes: ['source.crystal', 'constant.numeric.crystal']
    expect(tokens[3]).toEqual value: ' ', scopes: ['source.crystal']
    expect(tokens[4]).toEqual value: '/', scopes: ['source.crystal', 'keyword.operator.arithmetic.crystal']
    expect(tokens[5]).toEqual value: ' ', scopes: ['source.crystal']
    expect(tokens[6]).toEqual value: '2', scopes: ['source.crystal', 'constant.numeric.crystal']
    expect(tokens[7]).toEqual value: ')', scopes: ['source.crystal', 'punctuation.section.function.crystal']
    expect(tokens[8]).toEqual value: '.', scopes: ['source.crystal', 'punctuation.separator.method.crystal']
    expect(tokens[9]).toEqual value: 'split', scopes: ['source.crystal']
    expect(tokens[10]).toEqual value: '(', scopes: ['source.crystal', 'punctuation.section.function.crystal']
    expect(tokens[11]).toEqual value: '/', scopes: ['source.crystal', 'string.regexp.interpolated.crystal', 'punctuation.section.regexp.crystal']
    expect(tokens[12]).toEqual value: 'c', scopes: ['source.crystal', 'string.regexp.interpolated.crystal']
    expect(tokens[13]).toEqual value: '/', scopes: ['source.crystal', 'string.regexp.interpolated.crystal', 'punctuation.section.regexp.crystal']
    expect(tokens[14]).toEqual value: ')', scopes: ['source.crystal', 'punctuation.section.function.crystal']

    {tokens} = grammar.tokenizeLine('[/test/,3]')

    expect(tokens[0]).toEqual value: '[', scopes: ['source.crystal', 'punctuation.section.array.begin.crystal']
    expect(tokens[1]).toEqual value: '/', scopes: ['source.crystal', 'string.regexp.interpolated.crystal', 'punctuation.section.regexp.crystal']
    expect(tokens[2]).toEqual value: 'test', scopes: ['source.crystal', 'string.regexp.interpolated.crystal']
    expect(tokens[3]).toEqual value: '/', scopes: ['source.crystal', 'string.regexp.interpolated.crystal', 'punctuation.section.regexp.crystal']
    expect(tokens[4]).toEqual value: ',', scopes: ['source.crystal', 'punctuation.separator.object.crystal']

    {tokens} = grammar.tokenizeLine('[/test/]')

    expect(tokens[0]).toEqual value: '[', scopes: ['source.crystal', 'punctuation.section.array.begin.crystal']
    expect(tokens[1]).toEqual value: '/', scopes: ['source.crystal', 'string.regexp.interpolated.crystal', 'punctuation.section.regexp.crystal']
    expect(tokens[2]).toEqual value: 'test', scopes: ['source.crystal', 'string.regexp.interpolated.crystal']
    expect(tokens[3]).toEqual value: '/', scopes: ['source.crystal', 'string.regexp.interpolated.crystal', 'punctuation.section.regexp.crystal']

    {tokens} = grammar.tokenizeLine('/test/ && 4')

    expect(tokens[0]).toEqual value: '/', scopes: ['source.crystal', 'string.regexp.interpolated.crystal', 'punctuation.section.regexp.crystal']
    expect(tokens[1]).toEqual value: 'test', scopes: ['source.crystal', 'string.regexp.interpolated.crystal']
    expect(tokens[2]).toEqual value: '/', scopes: ['source.crystal', 'string.regexp.interpolated.crystal', 'punctuation.section.regexp.crystal']
    expect(tokens[3]).toEqual value: ' ', scopes: ['source.crystal']

    {tokens} = grammar.tokenizeLine('/test/ || 4')

    expect(tokens[0]).toEqual value: '/', scopes: ['source.crystal', 'string.regexp.interpolated.crystal', 'punctuation.section.regexp.crystal']
    expect(tokens[1]).toEqual value: 'test', scopes: ['source.crystal', 'string.regexp.interpolated.crystal']
    expect(tokens[2]).toEqual value: '/', scopes: ['source.crystal', 'string.regexp.interpolated.crystal', 'punctuation.section.regexp.crystal']
    expect(tokens[3]).toEqual value: ' ', scopes: ['source.crystal']

    {tokens} = grammar.tokenizeLine('/test/ ? 4 : 3')

    expect(tokens[0]).toEqual value: '/', scopes: ['source.crystal', 'string.regexp.interpolated.crystal', 'punctuation.section.regexp.crystal']
    expect(tokens[1]).toEqual value: 'test', scopes: ['source.crystal', 'string.regexp.interpolated.crystal']
    expect(tokens[2]).toEqual value: '/', scopes: ['source.crystal', 'string.regexp.interpolated.crystal', 'punctuation.section.regexp.crystal']
    expect(tokens[3]).toEqual value: ' ', scopes: ['source.crystal']

    {tokens} = grammar.tokenizeLine('/test/ : foo')

    expect(tokens[0]).toEqual value: '/', scopes: ['source.crystal', 'string.regexp.interpolated.crystal', 'punctuation.section.regexp.crystal']
    expect(tokens[1]).toEqual value: 'test', scopes: ['source.crystal', 'string.regexp.interpolated.crystal']
    expect(tokens[2]).toEqual value: '/', scopes: ['source.crystal', 'string.regexp.interpolated.crystal', 'punctuation.section.regexp.crystal']
    expect(tokens[3]).toEqual value: ' ', scopes: ['source.crystal']

    {tokens} = grammar.tokenizeLine('{a: /test/}')

    expect(tokens[4]).toEqual value: '/', scopes: ['source.crystal', 'string.regexp.interpolated.crystal', 'punctuation.section.regexp.crystal']
    expect(tokens[5]).toEqual value: 'test', scopes: ['source.crystal', 'string.regexp.interpolated.crystal']
    expect(tokens[6]).toEqual value: '/', scopes: ['source.crystal', 'string.regexp.interpolated.crystal', 'punctuation.section.regexp.crystal']

  it "tokenizes the / arithmetic operator", ->
    {tokens} = grammar.tokenizeLine('call/me/maybe')
    expect(tokens[0]).toEqual value: 'call', scopes: ['source.crystal']
    expect(tokens[1]).toEqual value: '/', scopes: ['source.crystal', 'keyword.operator.arithmetic.crystal']
    expect(tokens[2]).toEqual value: 'me', scopes: ['source.crystal']
    expect(tokens[3]).toEqual value: '/', scopes: ['source.crystal', 'keyword.operator.arithmetic.crystal']
    expect(tokens[4]).toEqual value: 'maybe', scopes: ['source.crystal']


    {tokens} = grammar.tokenizeLine('(1+2)/3/4')
    expect(tokens[0]).toEqual value: '(', scopes: ['source.crystal', 'punctuation.section.function.crystal']
    expect(tokens[1]).toEqual value: '1', scopes: ['source.crystal', 'constant.numeric.crystal']
    expect(tokens[2]).toEqual value: '+', scopes: ['source.crystal', 'keyword.operator.arithmetic.crystal']
    expect(tokens[3]).toEqual value: '2', scopes: ['source.crystal', 'constant.numeric.crystal']
    expect(tokens[4]).toEqual value: ')', scopes: ['source.crystal', 'punctuation.section.function.crystal']
    expect(tokens[5]).toEqual value: '/', scopes: ['source.crystal', 'keyword.operator.arithmetic.crystal']
    expect(tokens[6]).toEqual value: '3', scopes: ['source.crystal', 'constant.numeric.crystal']
    expect(tokens[7]).toEqual value: '/', scopes: ['source.crystal', 'keyword.operator.arithmetic.crystal']
    expect(tokens[8]).toEqual value: '4', scopes: ['source.crystal', 'constant.numeric.crystal']

    {tokens} = grammar.tokenizeLine('1 / 2 / 3')
    expect(tokens[0]).toEqual value: '1', scopes: ['source.crystal', 'constant.numeric.crystal']
    expect(tokens[1]).toEqual value: ' ', scopes: ['source.crystal']
    expect(tokens[2]).toEqual value: '/', scopes: ['source.crystal', 'keyword.operator.arithmetic.crystal']
    expect(tokens[3]).toEqual value: ' ', scopes: ['source.crystal']
    expect(tokens[4]).toEqual value: '2', scopes: ['source.crystal', 'constant.numeric.crystal']
    expect(tokens[5]).toEqual value: ' ', scopes: ['source.crystal']
    expect(tokens[6]).toEqual value: '/', scopes: ['source.crystal', 'keyword.operator.arithmetic.crystal']
    expect(tokens[7]).toEqual value: ' ', scopes: ['source.crystal']
    expect(tokens[8]).toEqual value: '3', scopes: ['source.crystal', 'constant.numeric.crystal']

    {tokens} = grammar.tokenizeLine('1/ 2 / 3')
    expect(tokens[0]).toEqual value: '1', scopes: ['source.crystal', 'constant.numeric.crystal']
    expect(tokens[1]).toEqual value: '/', scopes: ['source.crystal', 'keyword.operator.arithmetic.crystal']
    expect(tokens[2]).toEqual value: ' ', scopes: ['source.crystal']
    expect(tokens[3]).toEqual value: '2', scopes: ['source.crystal', 'constant.numeric.crystal']
    expect(tokens[4]).toEqual value: ' ', scopes: ['source.crystal']
    expect(tokens[5]).toEqual value: '/', scopes: ['source.crystal', 'keyword.operator.arithmetic.crystal']
    expect(tokens[6]).toEqual value: ' ', scopes: ['source.crystal']
    expect(tokens[7]).toEqual value: '3', scopes: ['source.crystal', 'constant.numeric.crystal']

    {tokens} = grammar.tokenizeLine('1 / 2/ 3')
    expect(tokens[0]).toEqual
      value: '1', scopes: ['source.crystal', 'constant.numeric.crystal']
    expect(tokens[1]).toEqual value: ' ', scopes: ['source.crystal']
    expect(tokens[2]).toEqual value: '/', scopes: ['source.crystal', 'keyword.operator.arithmetic.crystal']
    expect(tokens[3]).toEqual value: ' ', scopes: ['source.crystal']
    expect(tokens[4]).toEqual value: '2', scopes: ['source.crystal', 'constant.numeric.crystal']
    expect(tokens[5]).toEqual value: '/', scopes: ['source.crystal', 'keyword.operator.arithmetic.crystal']
    expect(tokens[6]).toEqual value: ' ', scopes: ['source.crystal']
    expect(tokens[7]).toEqual value: '3', scopes: ['source.crystal', 'constant.numeric.crystal']

  it "tokenizes the 'Hello World' example", ->
    {tokens} = grammar.tokenizeLine('puts "Hello world!"')
    expect(tokens[0]).toEqual value: 'puts', scopes: ['source.crystal', 'support.function.kernel.crystal']
    expect(tokens[1]).toEqual value: ' ', scopes: ['source.crystal']
    expect(tokens[2]).toEqual value: '"', scopes: ['source.crystal', 'string.quoted.double.crystal', 'punctuation.definition.string.begin.crystal']
    expect(tokens[3]).toEqual value: 'Hello world!', scopes: ['source.crystal', 'string.quoted.double.crystal']
    expect(tokens[4]).toEqual value: '"', scopes: ['source.crystal', 'string.quoted.double.crystal', 'punctuation.definition.string.end.crystal']

  it "tokenizes requires", ->
    {tokens} = grammar.tokenizeLine('require "http/server"')
    expect(tokens[0]).toEqual value: 'require', scopes: ['source.crystal', 'meta.require.crystal', 'keyword.other.special-method.crystal']
    expect(tokens[1]).toEqual value: ' ', scopes: ['source.crystal', 'meta.require.crystal']
    expect(tokens[2]).toEqual value: '"', scopes: ['source.crystal', 'meta.require.crystal', 'string.quoted.double.crystal', 'punctuation.definition.string.begin.crystal']
    expect(tokens[3]).toEqual value: 'http/server', scopes: ['source.crystal', 'meta.require.crystal', 'string.quoted.double.crystal']
    expect(tokens[4]).toEqual value: '"', scopes: ['source.crystal', 'meta.require.crystal', 'string.quoted.double.crystal', 'punctuation.definition.string.end.crystal']
