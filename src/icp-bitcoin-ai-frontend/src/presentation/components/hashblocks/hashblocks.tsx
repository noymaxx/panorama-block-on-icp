import React, { useRef, useState } from 'react'
import styles from './hashblocks-styles.module.scss'

const Hashblocks: React.FC = () => {
  const hashblocksRef = useRef<any>(null)
  const [isMouseDown, setIsMouseDown] = useState(false)
  const [startX, setStartX] = useState(0)
  const [scrollLeft, setScrollLeft] = useState(0)

  const handleMouseDown = (e: any) => {
    setIsMouseDown(true)
    setStartX(e.pageX - hashblocksRef.current.offsetLeft)
    setScrollLeft(hashblocksRef.current.scrollLeft)
  }

  const handleMouseUp = () => {
    setIsMouseDown(false)
  }

  const handleMouseLeave = () => {
    setIsMouseDown(false)

  }

  const handleMouseMove = (e: any) => {
    if (!isMouseDown) return
    e.preventDefault()
    const x = e.pageX - hashblocksRef.current.offsetLeft
    const walk = (x - startX) * 2
    hashblocksRef.current.scrollLeft = scrollLeft - walk
  }

  return (
    <div className={styles.container}>
      <h2>HASHBLOCKS</h2>
      <div
        className={styles.hashblocks}
        ref={hashblocksRef}
        onMouseDown={handleMouseDown}
        onMouseUp={handleMouseUp}
        onMouseLeave={handleMouseLeave}
        onMouseMove={handleMouseMove}
      >
        <div className={styles.card} draggable={false}>
          <div className={styles.info}>
            <p className={styles.id}>id [...]</p>
            <div className={styles.value}>
              <p>845,442</p>
            </div>
            <div className={styles.graph}>
              <img src="/graph.png" alt="" />
            </div>
          </div>
        </div>

        <div className={styles.card}>
          <div className={styles.info}>
            <p className={styles.id}>id [...]</p>
            <div className={styles.value}>
              <p>845,442</p>
            </div>
            <div className={styles.graph}>
              <img src="/graph.png" alt="" />
            </div>
          </div>
        </div>

        <div className={styles.card}>
          <div className={styles.info}>
            <p className={styles.id}>id [...]</p>
            <div className={styles.value}>
              <p>845,442</p>
            </div>
            <div className={styles.graph}>
              <img src="/graph.png" alt="" />
            </div>
          </div>
        </div>

        <div className={styles.card}>
          <div className={styles.info}>
            <p className={styles.id}>id [...]</p>
            <div className={styles.value}>
              <p>845,442</p>
            </div>
            <div className={styles.graph}>
              <img src="/graph.png" alt="" />
            </div>
          </div>
        </div>

        <div className={styles.card}>
          <div className={styles.info}>
            <p className={styles.id}>id [...]</p>
            <div className={styles.value}>
              <p>845,442</p>
            </div>
            <div className={styles.graph}>
              <img src="/graph.png" alt="" />
            </div>
          </div>
        </div>

        <div className={styles.card}>
          <div className={styles.info}>
            <p className={styles.id}>id [...]</p>
            <div className={styles.value}>
              <p>845,442</p>
            </div>
            <div className={styles.graph}>
              <img src="/graph.png" alt="" />
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}

export default Hashblocks