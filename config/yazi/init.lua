Status:children_add(function(self)
  local h = self._current.hovered
  if h and h.link_to then
    return " -> " .. tostring(h.link_to)
  else
    return ""
  end
end, 3300, Status.LEFT)

require("starship"):setup()

require("bookmarks"):setup({
  last_directory = { enable = true, persist = true, mode = "jump" },
  persist = "all",
  desc_format = "parent",
  file_pick_mode = "parent",
  custom_desc_input = true,
})
