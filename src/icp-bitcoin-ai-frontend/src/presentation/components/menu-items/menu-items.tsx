import React, { useState } from 'react'
import styles from './menu-items-styles.module.scss'

type Item = {
  title: string
  icon: string
  url?: string
}

type Props = {
  active?: string
  title?: string
  items: Item[]
  action?: (value: string) => void
}

const MenuItems: React.FC<Props> = ({ active, title, items, action }: Props) => {
  return (
    <div className={styles.menu}>
      {title && <h2 className={styles.title}>{title}</h2>}
      {
        items && items.map((item: Item, index: number) => {
          return (
            <div className={`${styles.item} ${active === item.title && styles.active}`} onClick={(() => { action?.(item.title) })}>
              <div className={styles.icon}>
                <img src={item.icon} alt="" />
              </div>
              <p>{item.title}</p>
            </div>
          )
        })
      }
    </div>
  )
}

export default MenuItems