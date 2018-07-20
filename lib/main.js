exports.activate = function() {
  if (!atom.grammars.addInjectionPoint) return

  atom.grammars.addInjectionPoint('ruby', {
    type: 'heredoc_body',

    language (node) {
      return node.lastChild.text
    },

    content (node) {
      return node
    }
  })
}
