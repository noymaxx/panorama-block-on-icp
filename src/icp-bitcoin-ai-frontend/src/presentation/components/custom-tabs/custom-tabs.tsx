import React, { ReactElement } from 'react'
import styles from './custom-tabs-styles.module.scss'
import { Box, Tab, Tabs } from '@mui/material'
import { TabContext, TabPanel } from '@mui/lab'
import AdvancedBarChart from '../advanced-bar-chart/advanced-bar-chart'

type Props = {
  labels: string[]
}

const CustomTabs: React.FC<Props> = ({ labels }: Props) => {
  const [value, setValue] = React.useState('0')

  const handleChange = (event: React.SyntheticEvent, newValue: string) => {
    setValue(newValue)
  }

  return (
    <div className={styles.tabs}>
      <TabContext value={value}>
        <Box sx={{ display: 'flex', height: '60px', padding: '8px', borderBottom: 1, borderColor: 'divider' }}>
          <Tabs
            sx={{ marginBottom: '4px' }}
            value={value}
            onChange={handleChange}
            aria-label="chart tabs"
          >
            {labels.map((label: string, index: number) => {
              return <Tab autoCapitalize='false' className={styles.tab} label={label} value={index.toString()} key={`tab - ${index}`} />
            })}
          </Tabs>
        </Box>


        {
          labels.map((panel: any, index: number) => {
            return <TabPanel className={styles.panel} sx={{ display: index.toString() === value ? 'flex' : 'none', width: '100%', height: '100%' }} value={index.toString()} key={`panel - ${index}`}>
              {panel && <AdvancedBarChart />}
            </TabPanel>
          })
        }
      </TabContext>
    </div >
  )
}

export default CustomTabs