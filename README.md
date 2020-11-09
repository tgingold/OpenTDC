# OpenTDC

## Introduction

What is a TDC ?  TDC stands for Time to Digital Converter.  It's a device
that is able to timestamp a pulse (as accurately as possible).

What are the use cases ?  It is used to measure distances using
time-of-flight of laser pulses, or time-of-flight of particules and
even in LIDAR.

The first implementation is based only on standard cells, using a naive
and simple approach.  The purpose of the first implementation is to have
a working design.

## Principle

There are two parts in the measure: the coarse part and the fine part.
The coarse part is simply a counter.  Its accuracy is limited by the clock
frequency.  To go beyond the clock frequency (the fine part), various points
of a delay line are sampled.
