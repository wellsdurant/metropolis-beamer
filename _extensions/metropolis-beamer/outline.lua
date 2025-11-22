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
    for i, block in ipairs(blocks) do
      if block.t == "Header" and block.level == 1 then
        table.insert(h1_titles, str(block.content))
      end
    end

    -- If no H1 headings found, don't create outline
    if #h1_titles == 0 then
      return doc
    end

    -- Create list of H1 titles
    local list_items = {}
    for i, title in ipairs(h1_titles) do
      table.insert(list_items, {pandoc.Plain({pandoc.Str(title)})})
    end

    -- Create the outline slide content with bullet list
    local outline_content = {
      pandoc.Header(2, {pandoc.Str("Outline")}),
      pandoc.BulletList(list_items)
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

    return pandoc.Pandoc(blocks, meta)
  end
end
