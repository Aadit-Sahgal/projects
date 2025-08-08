import React, { useContext } from 'react';
import { ActivityIndicator, View } from 'react-native';
import { NavigationContainer } from '@react-navigation/native';
import { AuthProvider, AuthContext } from './context/AuthContext';
import AuthStack from './navigation/AuthStack';
import AppStack  from './navigation/AppStack';

function Root() {
  const { token, loading } = useContext(AuthContext);
  if (loading) return <View style={{flex:1,justifyContent:'center'}}><ActivityIndicator size="large"/></View>;
  return <NavigationContainer>{token ? <AppStack/> : <AuthStack/>}</NavigationContainer>;
}

export default () => <AuthProvider><Root/></AuthProvider>;