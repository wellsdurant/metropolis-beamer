--[[
MIT License

Copyright (c) 2024 Shafayet Khan Shafee

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
]]--

local str = pandoc.utils.stringify

if quarto.doc.is_format('revealjs') then
  function Pandoc(doc)
    local blocks = doc.blocks
    local meta = doc.meta

    -- Check if outline should be generated (default: true)
    local generate_outline = true
    if meta['outline'] ~= nil then
      generate_outline = meta['outline']
    end

    if not generate_outline then
      return doc
    end

    -- Collect all H1 headings
    local h1_titles = {}
    local h1_positions = {}
    for i, block in ipairs(blocks) do
      if block.t == "Header" and block.level == 1 then
        table.insert(h1_titles, str(block.content))
        table.insert(h1_positions, i)
      end
    end

    -- If no H1 headings found, don't create outline
    if #h1_titles == 0 then
      return doc
    end

    -- Function to create simple outline list without highlighting
    local function create_simple_outline_list()
      local list_items = {}
      for i, title in ipairs(h1_titles) do
        table.insert(list_items, {pandoc.Plain({pandoc.Str(title)})})
      end
      return pandoc.BulletList(list_items)
    end

    -- Function to create outline list with current item marked
    local function create_outline_list(current_title)
      local list_items = {}
      for i, title in ipairs(h1_titles) do
        local item_content = {pandoc.Str(title)}
        local item = {pandoc.Plain(item_content)}
        -- Add data attribute to mark current item
        if title == current_title then
          table.insert(list_items, pandoc.Div(item, {["data-current"] = "true"}))
        else
          table.insert(list_items, pandoc.Div(item, {["data-current"] = "false"}))
        end
      end
      return pandoc.BulletList(list_items)
    end

    -- Create the outline slide content with simple list (no graying)
    local outline_content = {
      pandoc.Header(2, {pandoc.Str("Outline")}),
      create_simple_outline_list()
    }

    -- Find the position after title slide to insert outline
    local insert_pos = 1
    for i, block in ipairs(blocks) do
      -- Skip past any title slide div
      if block.t == "Div" and block.classes:includes("title-slide") then
        insert_pos = i + 1
        break
      end
      -- Or skip past first Header if no title div found
      if block.t == "Header" then
        insert_pos = i
        break
      end
    end

    -- Insert outline slides at the position
    for i = #outline_content, 1, -1 do
      table.insert(blocks, insert_pos, outline_content[i])
    end

    -- Replace each H1 slide with outline-style slide (H2 "Outline" + contextual list)
    local offset = #outline_content  -- Account for inserted outline slide
    for idx, pos in ipairs(h1_positions) do
      local adjusted_pos = pos + offset + (idx - 1) -- Account for previously inserted lists
      local current_title = h1_titles[idx]

      -- Replace H1 with H2 "Outline" and add data attribute with original section name
      local h2_outline = pandoc.Header(2, {pandoc.Str("Outline")})
      h2_outline.attributes["data-section-name"] = current_title
      blocks[adjusted_pos] = h2_outline

      -- Insert contextual outline list after the H2
      local outline_list = create_outline_list(current_title)
      table.insert(blocks, adjusted_pos + 1, outline_list)
    end

    return pandoc.Pandoc(blocks, meta)
  end
end
