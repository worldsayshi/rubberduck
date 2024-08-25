local function trim_table(t)
	local start, finish = 1, #t
	while start <= #t and t[start] == "" do
		start = start + 1
	end
	while finish > start and t[finish] == "" do
		finish = finish - 1
	end
	return vim.list_slice(t, start, finish)
end

return trim_table
