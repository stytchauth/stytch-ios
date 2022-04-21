import Tagged

/// A tag type for ``Minutes``
public enum MinutesTag {}

/// A dedicated time-unit type to represent minutes.
public typealias Minutes = Tagged<MinutesTag, UInt>
