import React from 'react'
import { BrowserRouter, Route, Routes } from 'react-router-dom'
import Login from '../../presentation/pages/login/login'
import Home from '../../presentation/pages/home/home'

const Router: React.FC = () => {
  return (
    <BrowserRouter>
      <Routes>
        <Route path='/' element={<Login />} />
        <Route path='/home' element={<Home />} />
      </Routes>
    </BrowserRouter>
  )
}

export default Router
