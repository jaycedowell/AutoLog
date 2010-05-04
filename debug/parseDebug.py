#!/home/jdowell/local/bin/python

import os
import sys

from matplotlib.backends.backend_agg import FigureCanvasAgg
from matplotlib.figure import Figure
import numpy
import Image

def main(args):
	lst = []
	spp = []
	nl = []
	count = []
	frame = []
	
	
	logFile = args[0]
	lfh = open(logFile, "r")
	i = 1
	j = 1
	for line in lfh.readlines():
		if line.find('DEBUG') != 0:
			continue
		
		if line.find('ls -t') != -1 and line.find('skipping') == -1:
			fields = line.split()
			lst.append( int(fields[6]) )
			
			count.append(j)
			j = j + 1
			continue
		
		if line.find('_parse.pl') != -1:
			fields = line.split()
			spp.append( int(fields[5]) )
			continue
		
		if line.find('nextlog') != -1:
			fields = line.split()
			nl.append( int(fields[5]) )
			
			frame.append(i)
			i = i + 1
			continue
		
	lfh.close()
	
	print len(frame)
	print len(spp)
	
	fig = Figure(figsize=(5,5), dpi=100)
	ax = fig.add_subplot(111)
	canvas = FigureCanvasAgg(fig)
	
	ax.plot(count, lst)
	ax.set_xlabel('Frame Number')
	ax.set_ylabel('nextlog Time')

	canvas.draw()

	s = canvas.tostring_rgb()
	l,b,w,h = fig.bbox.bounds
	w, h = int(w), int(h)
	im = Image.fromstring( "RGB", (w,h), s)
	im.show()

	
if __name__ == "__main__":
	main(sys.argv[1:])
