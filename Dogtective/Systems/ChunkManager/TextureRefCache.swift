//
//  TextureRefCache.swift
//  Dogtective
//
//  Created by Fikrah Damar Huda on 13/05/26.
//

import SpriteKit

/// Reference-counted SKTexture cache. `acquire` loads or returns the existing
/// instance and bumps the count; `release` drops it from the cache when no
/// chunk still references it, so the underlying GPU memory can be reclaimed
/// once SKSpriteNodes also stop holding it.
final class TextureRefCache {

    typealias Loader = (String) -> SKTexture?

    private struct Entry {
        let texture: SKTexture
        var count: Int
    }

    private var entries: [String: Entry] = [:]
    private let loader: Loader

    init(loader: @escaping Loader) {
        self.loader = loader
    }

    @discardableResult
    func acquire(_ key: String) -> SKTexture? {
        if var entry = entries[key] {
            entry.count += 1
            entries[key] = entry
            return entry.texture
        }
        guard let texture = loader(key) else { return nil }
        entries[key] = Entry(texture: texture, count: 1)
        return texture
    }

    func release(_ key: String) {
        guard var entry = entries[key] else { return }
        entry.count -= 1
        if entry.count <= 0 {
            entries.removeValue(forKey: key)
        } else {
            entries[key] = entry
        }
    }

    func refCount(for key: String) -> Int { entries[key]?.count ?? 0 }
    func contains(_ key: String) -> Bool { entries[key] != nil }
}
