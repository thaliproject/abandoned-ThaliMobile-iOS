# 3 - Native performance measurements

[Thali Project Stories](http://thaliproject.org/stories) Section 3


## How long does discovery take from the perspective of the searchable device and the searching device?

### Bluetooth Low Energy Connectivity Framework - Peer Bluetooth

1-2 seconds.

* At least one app instance must be in the foreground.
* Because of duplicate removal, special tricks are needed. When a peer is discovered over BTLE, it will not be discovered again.
Out Peer Bluetooth layer works around this issue by issuing an outstanding
connect request to any peer it has previously discovered.

### Multipeer Connectivity Framework - Peer Networking

2-4 seconds. 

* All apps muse be in the foreground.
* There are times when peer discovery refuses to work at all.

## What is the average battery consumption/hour for trying to discover without advertising?

### Bluetooth Low Energy Connectivity Framework - Peer Bluetooth

Very, very low. Negligible.

* This is true as long as `CBCentralManagerScanOptionAllowDuplicatesKey` is set to `NO`.
Setting `CBCentralManagerScanOptionAllowDuplicatesKey` to `YES` causes a dramatic
increase in battery consumption as roughly 60 Hz of notifications with RSSI are sent.

### Multipeer Connectivity Framework - Peer Networking

Problematic metric as Multipeer Connectivity Framework does not work
at all in the background. Therefore, screen battery consumption in
the foreground is the predominate consumer of power.

## What is the average battery consumption/hour for advertising

### Bluetooth Low Energy Connectivity Framework - Peer Bluetooth

Very, very low. Negligible.

### Multipeer Connectivity Framework - Peer Networking

Problematic metric as Multipeer Connectivity Framework does not work 
at all in the background.

How long does it take to successfully transmit the first byte?

2-4 seconds after connection is established.

What is the bandwidth that can be successfully sustained, including error recovery?

1-4 MB/s.

What is the battery consumption/megabyte of data transferred?

Problematic metric as Multipeer Connectivity Framework does not work
at all in the background. Therefore, screen battery consumption in
the foreground is the predominate consumer of power. We did not run
standing tests with transfer and standing tests without transfer because
of this.

## What is the data rate in MB/s we can stream data from memory to disk?

40-100 MB/s write

* This varies widely based on the age of the iPhone, its model, and whether
the phone has MLC or TLC flash. However, it's > 25 MB/s.
* iPhone 6 Plus has 93 MB/s write.

## What is the data rate in MB/s we can stream data from disk to memory?

70-800 MB/s read

* This varies widely based on the age of the iPhone, its model, and whether
the phone has MLC or TLC flash. However, it's > 50 MB/s.
* iPhone 6 Plus has 760 MB/s read.
