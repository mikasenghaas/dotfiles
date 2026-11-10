local M = {}

-- Line-number-prefixed quoting (`  13 | code`) rather than `> code`: the receiving agent has to
-- map each quoted line back to a position in the file, and counting down from a range header is
-- the step it gets wrong. Source tabs pass through verbatim, so a quoted line stays byte-identical
-- to the file and a patch built from it does not corrupt indentation.
local MAX_SNIPPET_LINES = 200

function M.item(c, snippet, max)
	max = max or MAX_SNIPPET_LINES
	snippet = not c.whole_file and snippet or {}

	local head = c.whole_file and c.file
		or string.format("%s:%d-%d", c.file, c.start_line, c.end_line)
	if c.modified then
		head = head .. " [unsaved]"
	end
	local lines = { head }

	local shown = math.min(max, #snippet)
	local width = #tostring(c.start_line + math.max(shown, 1) - 1)
	for j = 1, shown do
		if snippet[j] == "" then
			table.insert(lines, string.format("   %" .. width .. "d |", c.start_line + j - 1))
		else
			table.insert(
				lines,
				string.format("   %" .. width .. "d | %s", c.start_line + j - 1, snippet[j])
			)
		end
	end
	if #snippet > shown then
		table.insert(
			lines,
			string.format(
				"   ... %d more line(s) omitted, through line %d; read the file for the rest",
				#snippet - shown,
				c.end_line
			)
		)
	end

	table.insert(lines, "")
	if c.text and c.text ~= "" then
		vim.list_extend(lines, vim.split(c.text, "\n", { plain = true }))
	end

	return lines
end

function M.format(items)
	local any_unsaved = false
	for _, item in ipairs(items) do
		if item.comment and item.comment.modified then
			any_unsaved = true
		end
	end

	local lines = {
		string.format("%d comment%s:", #items, #items == 1 and "" or "s"),
	}
	if any_unsaved then
		table.insert(
			lines,
			"Items marked [unsaved] quote my editor buffer, which holds changes not yet written to disk."
		)
	end

	for _, item in ipairs(items) do
		table.insert(lines, "")
		vim.list_extend(lines, vim.split(item.comment.text, "\n", { plain = true }))
	end

	return table.concat(lines, "\n")
end

return M
