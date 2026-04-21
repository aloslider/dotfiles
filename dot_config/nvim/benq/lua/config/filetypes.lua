vim.filetype.add({
  pattern = {
    [".*%.tmpl"] = function(path, _)
      local ext = path:match("%.(%w+)%.tmpl$")
      if ext then
        return ext
      end

      return "template"
    end,
  },
})
