def _golden(in_bits):
    # Initialize output dictionary
    output = {'out': 0, 'valid': 0}

    # Check the priority of input bits and set the output accordingly
    if in_bits[3]:
        output['out'] = 0b11
        output['valid'] = 1
    elif in_bits[2]:
        output['out'] = 0b10
        output['valid'] = 1
    elif in_bits[1]:
        output['out'] = 0b01
        output['valid'] = 1
    elif in_bits[0]:
        output['out'] = 0b00
        output['valid'] = 1
    else:
        output['out'] = 0b00
        output['valid'] = 0

    return output