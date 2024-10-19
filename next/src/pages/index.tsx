import { Box, Grid, Container } from '@mui/material'
import camelcaseKeys from 'camelcase-keys'
import type { NextPage } from 'next'
import Link from 'next/link'
import useSWR from 'swr'
import ArticleCard from '@/pages/components/ArticleCard'
import Error from '@/pages/components/Error'
import Loading from '@/pages/components/Loading'
import { styles } from '@/styles/index'
import { fetcher } from '@/utils'

type ArticleProps = {
  id: number
  title: string
  createAt: string
  fromToday: string
  user: {
    name: string
  }
}

const Index: NextPage = () => {
  const url = 'http://localhost:3000/api/v1/articles'
  const { data, error } = useSWR(url, fetcher)

  if (error) return <Error />
  if (!data) return <Loading />

  const articles = camelcaseKeys(data.articles)

  return (
    <Box sx={{ backgroundColor: '#e6f2ff' }} css={styles.pageMinHeight}>
      <Container maxWidth="md" sx={{ pt: 6 }}>
        <Grid container spacing={4}>
          {articles.map((article: ArticleProps, i: number) => (
            <Grid key={i} item xs={12} md={6}>
              <Link href={'/articles/' + article.id}>
                <ArticleCard
                  title={article.title}
                  fromToday={article.fromToday}
                  userName={article.user.name}
                />
              </Link>
            </Grid>
          ))}
        </Grid>
      </Container>
    </Box>
  )
}

export default Index
