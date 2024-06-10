import React, { FormEvent, useState } from 'react'
import styles from './header-styles.module.scss'
import { Button, TextField } from '@mui/material'

type Props = {
  onSubmit: () => void
}

const Header: React.FC<Props> = ({ onSubmit }: Props) => {
  const [values, setValues] = useState({
    address: '',
    addressError: '',
    transaction: '',
    transactionError: ''
  })
  const handleSubmit = (e: FormEvent<HTMLFormElement>) => {
    e.preventDefault()
  }

  const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const { value, id } = e.target
    if (value) {
      setValues({ ...values, [id]: value })
    }
    else {
      setValues({ ...values, [`${id}Error`]: 'error' })
    }
  }

  return (
    <div className={styles.header}>
      <form onSubmit={handleSubmit}>
        <TextField
          required
          className={styles.textField}
          id="address"
          variant="outlined"
          placeholder="Address"
          size="small"
          onChange={handleChange}
        />
        <Button className={styles.button} type='submit'>Get address info</Button>
      </form>

      <form onSubmit={handleSubmit}>
        <TextField
          required
          className={styles.textField}
          id="transaction"
          variant="outlined"
          placeholder="Transaction"
          size="small"
          onChange={handleChange}
        />
        <Button className={styles.button} type='submit'>Get transaction info</Button>
      </form>
    </div>
  )
}

export default Header