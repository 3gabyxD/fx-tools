function map(inputMin, inputMax, outputMin, outputMax, x)
	return outputMin + ((outputMax - outputMin) / (inputMax - inputMin)) * (x - inputMin)
end

-- output_start + ((output_end - output_start) / (input_end - input_start)) * (input - input_start)

return map