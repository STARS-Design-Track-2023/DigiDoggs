#!/usr/bin/python3
from binary_fractions import Binary

def mandelbrot(c: complex):
    z = complex(0)
    iter = 0
    print_as_fixed_point(z)
    while abs(z) < 2 and iter < 255:
        z = z**2 + c
        print_as_fixed_point(z)
        iter += 1
    return iter

def print_as_fixed_point(c: complex):
    a = Binary(c.real).to_twoscomplement(32)
    b = Binary(c.imag).to_twoscomplement(32)
    
    print(a, b)

if __name__ == '__main__':
    c = complex('-1+0.5j')

    print(mandelbrot(c))
