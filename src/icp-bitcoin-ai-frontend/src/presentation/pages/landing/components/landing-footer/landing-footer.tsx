import React from 'react'
import styles from './landing-footer-styles.module.scss'

const LandingFooter: React.FC = () => {
  return (
    <div className={styles.landingFooter}>
      <h2 className={styles.title}>Panorama Block</h2>

      <p className={styles.copyright}>
        Copyright © 2024 - All rights reserved.
      </p>
    </div>
  )
}

export default LandingFooter