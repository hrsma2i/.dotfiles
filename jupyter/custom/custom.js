// 行数表示
var cell = Jupyter.notebook.get_selected_cell();
var config = cell.config;
var patch = {
    CodeCell: {
        cm_config: { lineNumbers: true }
    }
}
config.update(patch)

// Configure CodeMirror
require([
    'nbextensions/vim_binding/vim_binding', // depends your installation
], function() {
    // Map jj to <Esc>
    CodeMirror.Vim.map("jj", "<Esc>", "insert");
    // Swap j/k and gj/gk (Note that <Plug> mappings)
    CodeMirror.Vim.map("j", "<Plug>(vim-binding-gj)", "normal");
    CodeMirror.Vim.map("k", "<Plug>(vim-binding-gk)", "normal");
    CodeMirror.Vim.map("gj", "<Plug>(vim-binding-j)", "normal");
    CodeMirror.Vim.map("gk", "<Plug>(vim-binding-k)", "normal");
});

MathJax.Hub.Config({
    "HTML-CSS": {
        /*preferredFont: "TeX",*/
        /*availableFonts: ["TeX", "STIX"],*/
        styles: {
            scale: 100,
            ".MathJax_Display": {
                "font-size": "100%",
            }
        }
    }
});
