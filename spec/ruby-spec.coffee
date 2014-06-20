# Run specs on the Ruby language package
#
# While editiong this package in Atom, use the `Run Package Specs`
# and observe the output.
describe 'Ruby grammar', ->
  grammar = null

  beforeEach ->
    waitsForPromise ->
      atom.packages.activatePackage('language-ruby')

    runs ->
      grammar = atom.syntax.grammarForScopeName('source.ruby')

  it 'parses the grammar', ->
    expect(grammar).toBeTruthy()
    expect(grammar.scopeName).toBe 'source.ruby'

  it 'tokenizes nil* variants in the correct scopes', ->
    test = (word) ->
      {tokens} = grammar.tokenizeLine(word)
      expect(tokens[0]).toEqual value: word, scopes: ['source.ruby', 'constant.language.nil.ruby']
    matchWords = ['nil', 'nil?', 'nil!']
    test word for word in matchWords
